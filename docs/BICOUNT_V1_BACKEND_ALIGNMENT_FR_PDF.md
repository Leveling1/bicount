# Bicount V1 - Alignement Backend Supabase

## Objet du document

Ce document décrit exactement ce que l'équipe backend doit mettre en place dans Supabase pour que la V1 mobile de Bicount fonctionne correctement avec l'application Flutter actuellement développée.

Date de référence:
- 18 mars 2026

Portée fonctionnelle de la V1:
- application mobile uniquement
- navigation visible: Home, Graphs, Transaction, Profile
- la partie company reste présente dans le code source mais n'est plus visible dans le parcours release
- partage de profil par lien HTTPS et QR code
- notifications push via FCM et rappels locaux sur appareil
- comportement offline first et temps réel dès que le backend le permet

## Ce qui existe déjà côté backend

D'après la documentation backend déjà fournie, les éléments suivants existent déjà:
- users
- companies
- company_with_user_link
- groups
- projects
- transactions
- friends
- subscriptions
- account_funding
- memoji

Fonctions et logiques déjà documentées:
- update_user_balances
- add_funds_to_the_balance
- add_subscriptions_to_the_balance
- fonctions Edge liées à company, group, project et au traitement des subscriptions

Important:
- rien de cela ne doit être supprimé pour la V1
- la V1 masque seulement la partie company dans l'interface mobile

## Ce que le backend doit ajouter pour la V1

Trois nouvelles tables doivent être ajoutées:
- friend_invites
- device_tokens
- notification_events

Une RPC doit être ajoutée:
- accept_friend_invite

Une Edge Function doit être ajoutée:
- send_push_notification

Realtime doit être activé sur:
- friend_invites
- friends
- transactions
- subscriptions
- account_funding

## Table friend_invites

Cette table sert à:
- créer une invitation ami
- partager un code ou un lien
- retrouver une invitation à partir d'un invite_code
- accepter ou rejeter l'invitation
- suivre l'état de l'invitation en temps réel

SQL recommandé:

```sql
create table public.friend_invites (
  invite_id uuid primary key default gen_random_uuid(),
  invite_code text not null unique,
  sender_uid uuid not null references auth.users(id) on delete cascade,
  sender_name text,
  sender_email text,
  sender_image text,
  receiver_uid uuid references auth.users(id) on delete set null,
  receiver_name text,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  updated_at timestamptz not null default now()
);

alter table public.friend_invites
add constraint friend_invites_status_check
check (status in ('pending', 'accepted', 'rejected', 'expired'));
```

Valeurs de status attendues par l'application:
- pending
- accepted
- rejected
- expired

## Table device_tokens

Cette table sert à:
- enregistrer les tokens FCM des appareils
- mettre à jour un token quand Firebase en donne un nouveau
- envoyer des notifications push à tous les appareils d'un utilisateur

SQL recommandé:

```sql
create table public.device_tokens (
  token_id uuid primary key default gen_random_uuid(),
  user_uid uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

Valeurs de platform recommandées:
- android
- iOS

## Table notification_events

Cette table sert à:
- journaliser les événements envoyés
- tracer les notifications push déclenchées
- préparer une éventuelle vue historique plus tard

SQL recommandé:

```sql
create table public.notification_events (
  event_id uuid primary key default gen_random_uuid(),
  user_uid uuid not null references auth.users(id) on delete cascade,
  category text not null,
  title text not null,
  body text,
  route text,
  payload jsonb not null default '{}'::jsonb,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);
```

Catégories attendues par l'application:
- friend_invite
- friend_accept
- transaction_created
- subscription_due
- subscription_changed

## Politiques RLS recommandées

### friend_invites

Objectif:
- un utilisateur lit les invitations qu'il a envoyées
- un utilisateur lit les invitations qu'il a reçues
- un utilisateur ne crée que ses propres invitations
- un utilisateur peut mettre à jour une invitation qu'il reçoit

SQL recommandé:

```sql
alter table public.friend_invites enable row level security;

create policy friend_invites_select_own
on public.friend_invites
for select
to authenticated
using (sender_uid = auth.uid() or receiver_uid = auth.uid());

create policy friend_invites_insert_own
on public.friend_invites
for insert
to authenticated
with check (sender_uid = auth.uid());

create policy friend_invites_update_sender_or_receiver
on public.friend_invites
for update
to authenticated
using (sender_uid = auth.uid() or receiver_uid = auth.uid())
with check (sender_uid = auth.uid() or receiver_uid = auth.uid());
```

### device_tokens

Objectif:
- un utilisateur lit seulement ses propres tokens
- un utilisateur insère ou met à jour seulement ses propres tokens

SQL recommandé:

```sql
alter table public.device_tokens enable row level security;

create policy device_tokens_select_own
on public.device_tokens
for select
to authenticated
using (user_uid = auth.uid());

create policy device_tokens_insert_own
on public.device_tokens
for insert
to authenticated
with check (user_uid = auth.uid());

create policy device_tokens_update_own
on public.device_tokens
for update
to authenticated
using (user_uid = auth.uid())
with check (user_uid = auth.uid());
```

### notification_events

Objectif:
- un utilisateur lit seulement ses propres événements
- l'insertion se fait via service role ou via une Edge Function de confiance

SQL recommandé:

```sql
alter table public.notification_events enable row level security;

create policy notification_events_select_own
on public.notification_events
for select
to authenticated
using (user_uid = auth.uid());
```

## RPC obligatoire: accept_friend_invite

L'application essaie déjà d'appeler une RPC nommée accept_friend_invite.

Signature recommandée:

```sql
accept_friend_invite(
  p_invite_code text,
  p_receiver_uid uuid
)
```

Comportement attendu:
1. chercher l'invitation par invite_code
2. vérifier qu'elle existe
3. vérifier qu'elle est encore pending
4. vérifier qu'elle n'est pas expirée
5. renseigner receiver_uid
6. passer status à accepted
7. créer la relation dans la table friends
8. si nécessaire, créer aussi la relation inverse
9. créer un événement de notification pour l'émetteur

Recommandation supplémentaire:
- prévoir une tâche planifiée qui passe automatiquement les invitations pending à expired quand expires_at est dépassé

## Ce que la table friends doit produire après acceptation

Après acceptation d'une invitation:
- le nouvel ami doit apparaître côté émetteur
- le nouvel ami doit apparaître côté destinataire
- si votre modèle nécessite deux lignes, il faut créer les deux lignes

Champs actuellement utilisés par l'application dans friends:
- uid
- fid
- image
- username
- email
- give
- receive
- relation_type
- personal_income
- company_income
- sid

Pour la V1:
- relation_type = 0 correspond à un ami classique

## Temps réel à activer

Activer Supabase Realtime sur:
- friend_invites
- friends
- transactions
- subscriptions
- account_funding

Pourquoi:
- friend_invites: mise à jour immédiate des invitations
- friends: mise à jour immédiate de la liste d'amis
- transactions, subscriptions et account_funding: mise à jour immédiate des graphiques

## Notifications push via FCM

## Ce que fait déjà l'application

L'application:
- demande la permission des notifications
- récupère le token FCM
- tente de sauvegarder le token dans device_tokens
- gère les messages en foreground, en background et à l'ouverture
- gère aussi des rappels locaux pour les subscriptions

## Ce que le backend doit faire

Créer une Edge Function dédiée, par exemple:
- send_push_notification

Entrées recommandées:
- user_uid
- title
- body
- category
- route optionnel
- payload optionnel

Comportement attendu:
1. récupérer tous les tokens de l'utilisateur dans device_tokens
2. envoyer la notification via FCM
3. écrire une ligne dans notification_events
4. supprimer ou désactiver les tokens invalides si FCM le signale

## Format de payload attendu par l'application

Exemple recommandé:

```json
{
  "category": "friend_invite",
  "title": "Nouvelle invitation",
  "body": "Louis vous a invité sur Bicount",
  "route": "/friend/invite?code=abc123",
  "invite_code": "abc123"
}
```

Autres catégories prévues:
- friend_accept
- transaction_created
- subscription_due
- subscription_changed

## Quand notifier

### Friend flow

Notifier:
- quand une invitation est créée
- quand une invitation est acceptée

Optionnel:
- quand une invitation est rejetée

### Transaction flow

Notifier:
- quand une transaction partagée impacte réellement un autre utilisateur

### Subscription flow

Notifier:
- quand une subscription importante est créée
- quand une subscription importante est modifiée

Note:
- les rappels de date d'échéance sont déjà gérés localement par l'application
- un push backend pour subscription_due reste pertinent si l'utilisateur a plusieurs appareils

## App links et deep links

Base URL actuellement utilisée par l'application:
- https://preview.bicount.app

Route attendue:
- /friend/invite?code=<invite_code>

Actions techniques à faire:
- héberger le domaine en HTTPS
- publier assetlinks.json pour Android
- publier apple-app-site-association pour iOS
- conserver exactement cette structure de route

Si le domaine final change:
- il faudra mettre à jour la variable d'environnement Flutter BICOUNT_INVITE_BASE_URL

## Ordre recommandé d'implémentation

1. créer friend_invites
2. créer device_tokens
3. créer notification_events
4. activer les RLS
5. implémenter accept_friend_invite
6. activer Realtime
7. créer l'Edge Function FCM
8. configurer les app links
9. tester avec deux appareils réels

## Cas de test backend minimum

### Cas 1 - Création d'une invitation
- l'utilisateur A crée une invitation
- une ligne apparaît dans friend_invites
- le code est unique

### Cas 2 - Lecture d'une invitation
- l'utilisateur B ouvre un lien avec un invite_code
- l'application retrouve l'invitation
- les données de l'invitation sont cohérentes

### Cas 3 - Acceptation
- l'utilisateur B accepte
- status passe à accepted
- receiver_uid est rempli
- friends est mis à jour
- l'utilisateur A reçoit un événement friend_accept

### Cas 4 - Device token
- un token FCM est inséré
- un changement de token met bien à jour les données

### Cas 5 - Push
- un événement friend_invite est envoyé
- le push est reçu
- le route ouvre la bonne vue dans l'application

## Ce qui reste volontairement inchangé pour la V1

- companies
- groups
- projects
- les fonctions backend déjà présentes autour de company
- la logique existante de balance utilisateur déjà documentée

## Résumé exécutif

Pour être aligné avec la V1 mobile actuelle, le backend doit ajouter:
- 3 tables: friend_invites, device_tokens, notification_events
- 1 RPC: accept_friend_invite
- 1 Edge Function FCM
- Realtime sur les tables utiles
- la configuration du domaine de deep link

Sans ces éléments:
- le partage de profil restera partiellement local
- l'acceptation distante ne sera pas complète
- les notifications push ne partiront pas

## Mise � jour 2026-03-19 - liaison d'un friend local vers un vrai compte

Le partage vise maintenant une ligne pr�cise de `public.friends`.

A ajouter dans `friend_invites` :

- `source_friend_sid text not null`
- `source_friend_name text`
- `source_friend_email text`
- `source_friend_image text`

A l'acceptation :

1. retrouver l'invitation par `invite_code`
2. remplir `receiver_uid`
3. mettre le statut � `accepted`
4. mettre � jour `public.friends.uid` sur la ligne identifi�e par `source_friend_sid`

Les nouveaux friends locaux cr��s par l'app arrivent maintenant avec `uid = null` tant qu'ils ne sont pas li�s.

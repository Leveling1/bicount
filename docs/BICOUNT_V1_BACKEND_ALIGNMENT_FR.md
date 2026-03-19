# Bicount V1 - Document d'alignement Backend

## Objectif

Ce document explique exactement ce que le backend Supabase doit exposer pour être aligné avec la V1 mobile actuellement implémentée dans l'application Flutter.

Date de référence:
- 18 mars 2026

Portée V1:
- mobile uniquement: Android + iOS
- navigation visible: `Home / Graphs / Transaction / Profile`
- la partie `company` reste dans le code source mais n'est plus dans le parcours release
- partage de profil par lien HTTPS + QR code
- notifications push via FCM + rappels locaux sur l'appareil
- fonctionnement offline-first + temps réel dès que le backend le permet

## Ce qui existe déjà côté backend

D'après la documentation backend fournie, les ressources suivantes existent déjà:
- `users`
- `companies`
- `company_with_user_link`
- `groups`
- `projects`
- `transactions`
- `friends`
- `subscriptions`
- `account_funding`
- `memoji`

Fonctions / logiques déjà documentées:
- `update_user_balances`
- `add_funds_to_the_balance`
- `add_subscriptions_to_the_balance`
- Edge Functions autour de `company`, `group`, `project` et du traitement des subscriptions

Important:
- rien de cela ne doit être supprimé pour la V1
- la V1 cache simplement la partie `company` dans l'interface

## Ce que l'application attend maintenant côté backend

### 1. Gestion des invitations amis

L'app attend une nouvelle table:
- `friend_invites`

Usage côté app:
- créer une invitation
- partager un lien ou un QR
- ouvrir le lien sur un autre appareil
- charger l'invitation par `invite_code`
- accepter ou refuser
- créer la relation amie après acceptation
- recevoir les changements en temps réel

### 2. Gestion des tokens push

L'app attend une nouvelle table:
- `device_tokens`

Usage côté app:
- enregistrer un token FCM par utilisateur
- mettre à jour le token quand FCM le renouvelle
- cibler les appareils lors des notifications

### 3. Historique / log des notifications

L'app attend une nouvelle table:
- `notification_events`

Usage côté back:
- journaliser les événements envoyés
- tracer ce qui a été notifié
- servir de base pour audit ou centre de notifications plus tard

## Schéma SQL recommandé

### Table `friend_invites`

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
```

Valeurs de `status` attendues par l'app:
- `pending`
- `accepted`
- `rejected`
- `expired`

Contraintes recommandées:

```sql
alter table public.friend_invites
add constraint friend_invites_status_check
check (status in ('pending', 'accepted', 'rejected', 'expired'));
```

### Table `device_tokens`

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

Valeurs de `platform` recommandées:
- `android`
- `iOS`

### Table `notification_events`

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

Catégories actuellement attendues par l'app:
- `friend_invite`
- `friend_accept`
- `transaction_created`
- `subscription_due`
- `subscription_changed`

## RLS à mettre en place

### `friend_invites`

Objectif:
- un utilisateur lit les invitations qu'il a envoyées
- un utilisateur lit les invitations qu'il a reçues
- un utilisateur ne crée que ses propres invitations
- un utilisateur peut mettre à jour une invitation qu'il reçoit lorsqu'il l'accepte ou la rejette

Politiques recommandées:

```sql
alter table public.friend_invites enable row level security;

create policy "friend_invites_select_own"
on public.friend_invites
for select
to authenticated
using (sender_uid = auth.uid() or receiver_uid = auth.uid());

create policy "friend_invites_insert_own"
on public.friend_invites
for insert
to authenticated
with check (sender_uid = auth.uid());

create policy "friend_invites_update_sender_or_receiver"
on public.friend_invites
for update
to authenticated
using (sender_uid = auth.uid() or receiver_uid = auth.uid())
with check (sender_uid = auth.uid() or receiver_uid = auth.uid());
```

### `device_tokens`

Objectif:
- un utilisateur lit seulement ses tokens
- un utilisateur insère ou met à jour seulement ses tokens

Politiques recommandées:

```sql
alter table public.device_tokens enable row level security;

create policy "device_tokens_select_own"
on public.device_tokens
for select
to authenticated
using (user_uid = auth.uid());

create policy "device_tokens_insert_own"
on public.device_tokens
for insert
to authenticated
with check (user_uid = auth.uid());

create policy "device_tokens_update_own"
on public.device_tokens
for update
to authenticated
using (user_uid = auth.uid())
with check (user_uid = auth.uid());
```

### `notification_events`

Objectif:
- un utilisateur lit seulement ses notifications
- l'insertion doit être faite par service role ou fonction backend de confiance

Politiques recommandées:

```sql
alter table public.notification_events enable row level security;

create policy "notification_events_select_own"
on public.notification_events
for select
to authenticated
using (user_uid = auth.uid());
```

## Fonction RPC obligatoire

### `accept_friend_invite`

L'app essaie déjà d'appeler une RPC nommée:
- `accept_friend_invite`

Signature recommandée:

```sql
accept_friend_invite(
  p_invite_code text,
  p_receiver_uid uuid
)
```

Comportement attendu:
1. chercher l'invitation par `invite_code`
2. vérifier qu'elle existe
3. vérifier qu'elle est encore `pending`
4. vérifier qu'elle n'est pas expirée
5. remplir `receiver_uid`
6. passer `status = 'accepted'`
7. créer la relation dans `friends`
8. idéalement créer aussi la relation inverse si votre modèle `friends` fonctionne en double entrée
9. créer un événement de notification pour prévenir l'émetteur

### Recommandation supplémentaire

Ajouter une fonction ou une tâche planifiée pour expirer automatiquement les invitations trop anciennes:
- passer `status = 'expired'` quand `expires_at < now()` et `status = 'pending'`

## Table `friends` existante: ce que la V1 attend

Lorsqu'une invitation est acceptée:
- la table `friends` doit être mise à jour
- le nouvel ami doit apparaître en temps réel sur les deux comptes si votre modèle le permet

L'app lit actuellement pour chaque ami:
- `uid`
- `fid`
- `image`
- `username`
- `email`
- `give`
- `receive`
- `relation_type`
- `personal_income`
- `company_income`
- `sid`

Pour la V1:
- `relation_type = 0` correspond à un ami classique

## Temps réel à activer

Activer Supabase Realtime sur:
- `friend_invites`
- `friends`
- `transactions`
- `subscriptions`
- `account_funding`

Pourquoi:
- `friend_invites`: mise à jour instantanée des invitations envoyées / reçues
- `friends`: affichage instantané des nouvelles relations
- `transactions`, `subscriptions`, `account_funding`: alimentation des graphes en temps réel

## Notifications push FCM

## Ce que fait déjà l'app

L'app:
- demande la permission notification
- récupère le token FCM
- essaie de le sauvegarder dans `device_tokens`
- reçoit les messages foreground / background / app ouverte
- gère aussi des rappels locaux pour les subscriptions

## Ce que le backend doit faire

Créer une Edge Function dédiée, par exemple:
- `send_push_notification`

Entrées recommandées:
- `user_uid`
- `title`
- `body`
- `category`
- `route` optionnel
- `payload` optionnel

Comportement:
1. récupérer les tokens dans `device_tokens`
2. envoyer via FCM
3. écrire dans `notification_events`
4. nettoyer les tokens invalides si FCM le signale

## Format de payload attendu par l'app

Exemple minimal:

```json
{
  "category": "friend_invite",
  "title": "Nouvelle invitation",
  "body": "Louis vous a invite sur Bicount",
  "route": "/friend/invite?code=abc123",
  "invite_code": "abc123"
}
```

Autres catégories utilisables:
- `friend_accept`
- `transaction_created`
- `subscription_due`
- `subscription_changed`

## Quand notifier

### Friend flow

Notifier:
- quand une invitation est créée
- quand une invitation est acceptée

Optionnel:
- quand une invitation est rejetée

### Transaction flow

Notifier:
- quand une transaction partagée a un impact sur un ami concerné

### Subscription flow

Notifier:
- quand une subscription importante est créée ou modifiée

Note:
- les rappels de date d'échéance sont déjà gérés localement sur l'appareil
- un push backend sur `subscription_due` reste utile si l'utilisateur possède plusieurs appareils

## Deep links / app links

Base URL actuellement utilisée par l'app:
- `https://preview.bicount.app`

Route attendue:
- `/friend/invite?code=<invite_code>`

Actions infra nécessaires:
- héberger ce domaine en HTTPS
- publier `assetlinks.json` pour Android
- publier `apple-app-site-association` pour iOS
- conserver exactement cette structure de route

Si le domaine change plus tard:
- mettre à jour la variable d'environnement Flutter `BICOUNT_INVITE_BASE_URL`

## Ordre recommandé d'implémentation côté backend

1. créer `friend_invites`
2. créer `device_tokens`
3. créer `notification_events`
4. activer les RLS
5. implémenter `accept_friend_invite`
6. activer Realtime
7. créer l'Edge Function FCM
8. publier la config app links
9. tester avec 2 appareils réels

## Cas de test backend minimum

### Cas 1 - Invitation
- utilisateur A crée une invitation
- la ligne apparaît dans `friend_invites`
- le code d'invitation est unique

### Cas 2 - Ouverture du lien
- utilisateur B ouvre `/friend/invite?code=...`
- l'app récupère l'invitation
- l'invitation est lisible si B est le destinataire ou si le flux d'acceptation le nécessite

### Cas 3 - Acceptation
- B accepte
- `status` passe à `accepted`
- `receiver_uid` est renseigné
- `friends` est mis à jour
- A reçoit un événement `friend_accept`

### Cas 4 - Token device
- connexion utilisateur
- token FCM sauvegardé dans `device_tokens`
- changement de token met bien la ligne à jour

### Cas 5 - Notification push
- envoi d'un événement `friend_invite`
- le push arrive
- le `route` ouvre la bonne vue dans l'app

## Points volontairement inchangés pour la V1

- tables `companies`, `groups`, `projects`
- edge functions liées à `company`
- structure métier existante autour des balances utilisateur déjà documentée

## Fichiers Flutter à considérer comme référence de contrat

Si le back veut vérifier le contrat exact attendu par l'app:
- [friend_repository_impl.dart](/C:/Users/louis/Documents/Projet/Young%20solver/Projets%20-%20Code/bicount/lib/features/friend/data/repositories/friend_repository_impl.dart)
- [supabase_friend_remote_data_source.dart](/C:/Users/louis/Documents/Projet/Young%20solver/Projets%20-%20Code/bicount/lib/features/friend/data/data_sources/remote_datasource/supabase_friend_remote_data_source.dart)
- [notification_repository_impl.dart](/C:/Users/louis/Documents/Projet/Young%20solver/Projets%20-%20Code/bicount/lib/features/notification/data/repositories/notification_repository_impl.dart)
- [firebase_notification_remote_data_source.dart](/C:/Users/louis/Documents/Projet/Young%20solver/Projets%20-%20Code/bicount/lib/features/notification/data/data_sources/remote_datasource/firebase_notification_remote_data_source.dart)
- [app_config.dart](/C:/Users/louis/Documents/Projet/Young%20solver/Projets%20-%20Code/bicount/lib/core/constants/app_config.dart)

## Résumé exécutif

Pour que la V1 fonctionne comme implémenté dans l'app, le backend doit ajouter:
- 3 nouvelles tables: `friend_invites`, `device_tokens`, `notification_events`
- 1 RPC: `accept_friend_invite`
- 1 Edge Function FCM
- Realtime sur les nouvelles tables utiles
- la configuration app links du domaine

Sans ces éléments:
- le partage de profil restera partiellement local
- l'acceptation distante ne sera pas complète
- les notifications push ne partiront pas

## Mise � jour 2026-03-19 - liaison d'un friend local vers un vrai compte

Le flux de partage a �volu�.

Nouveau comportement produit :

- un `friend` peut �tre cr�� localement et utilis� dans les transactions avant que la personne n'ait un compte Bicount
- les nouveaux `friends` locaux cr��s par l'application arrivent d�sormais avec `uid = null`
- pour compatibilit� avec des donn�es plus anciennes, le front consid�re aussi `uid = sid` et `fid = owner uid` comme un friend encore non li�
- le bouton de partage n'appara�t que pour un friend non li�, depuis l'�cran d�tail ami

Nouveau contrat backend requis :

- `friend_invites` ne repr�sente plus seulement une invitation g�n�rique
- chaque invitation doit cibler une ligne pr�cise de `public.friends`
- ajouter les colonnes suivantes dans `friend_invites` :
  - `source_friend_sid text not null`
  - `source_friend_name text`
  - `source_friend_email text`
  - `source_friend_image text`

� l'acceptation d'une invitation, la logique backend doit :

1. retrouver l'invitation via `invite_code`
2. v�rifier que l'invitation est encore valide
3. renseigner `receiver_uid`
4. passer le statut � `accepted`
5. mettre � jour `public.friends.uid` avec le vrai `uid` du compte qui accepte, sur la ligne identifi�e par `source_friend_sid`

C�t� app, l'�cran liste d�di� est maintenant `lib/features/friend/presentation/screens/friends_directory_screen.dart` et le d�tail temps r�el repose sur `lib/features/friend/domain/services/friend_view_service.dart`.

### Mise a jour unicite des device tokens

L'application mobile maintient maintenant une seule ligne active par `user_uid` dans `device_tokens`.

Durcissement recommande cote Supabase :

```sql
create unique index if not exists device_tokens_user_uid_unique
on public.device_tokens(user_uid);
```

Comportement attendu par l'app :

- si `user_uid` existe deja : mise a jour
- si `user_uid` n'existe pas : insertion
- si plusieurs lignes existent deja pour le meme `user_uid` : conservation d'une ligne et suppression des doublons

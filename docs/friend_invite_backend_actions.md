# Friend Invite Backend Actions

Ce document remplace le vieux contrat `friend_invites.status` en texte pour le flow de partage de profil.

Objectif:

- garder la table `friend_invites` protégée par RLS
- éviter le chargement direct public par `select` sur la table
- déplacer la preview et l'acceptation dans 2 Edge Functions
- passer les statuts d'invitation sur une table de référence avec des ids entiers

## 1. Migration des statuts

Créer une table de référence `friend_invites_statut`.

```sql
create table if not exists public.friend_invites_statut (
  id integer primary key,
  code text not null unique,
  label text not null
);
```

Remplir les statuts de base:

```sql
insert into public.friend_invites_statut (id, code, label)
values
  (0, 'pending', 'Pending'),
  (1, 'accepted', 'Accepted'),
  (2, 'rejected', 'Rejected'),
  (3, 'expired', 'Expired')
on conflict (id) do update
set
  code = excluded.code,
  label = excluded.label;
```

## 2. Modifier `friend_invites`

Ajouter la nouvelle colonne:

```sql
alter table public.friend_invites
add column if not exists status_id integer;
```

Backfill depuis l'ancien texte `status`:

```sql
update public.friend_invites
set status_id = case status
  when 'accepted' then 1
  when 'rejected' then 2
  when 'expired' then 3
  else 0
end
where status_id is null;
```

Rendre la colonne obligatoire et liée à la table de référence.

Important:

- la foreign key doit être en `NO ACTION`
- ne pas mettre `CASCADE`

```sql
alter table public.friend_invites
alter column status_id set not null;

alter table public.friend_invites
add constraint friend_invites_status_id_fkey
foreign key (status_id)
references public.friend_invites_statut(id)
on update no action
on delete no action;
```

Une fois le mobile et le backend alignés, supprimer l'ancienne colonne texte:

```sql
alter table public.friend_invites
drop column if exists status;
```

## 3. Index utiles

```sql
create index if not exists friend_invites_invite_code_idx
on public.friend_invites(invite_code);

create index if not exists friend_invites_sender_uid_idx
on public.friend_invites(sender_uid);

create index if not exists friend_invites_receiver_uid_idx
on public.friend_invites(receiver_uid);

create index if not exists friend_invites_status_id_idx
on public.friend_invites(status_id);

create index if not exists friend_invites_source_friend_sid_idx
on public.friend_invites(source_friend_sid);
```

## 4. RLS

On garde la RLS sur `friend_invites`.

But:

- l'app ne doit plus faire de preview publique par `select`
- les Edge Functions porteront la logique sensible

Donc:

- garder les policies sender/receiver pour les usages authentifiés normaux
- ne pas ouvrir une policy publique large juste pour la preview

## 5. Edge Function `friend-invite-preview`

### But

Retourner la preview d'une invitation à partir de `invite_code` sans exposer directement la table `friend_invites`.

### Entrée

Body JSON:

```json
{
  "invite_code": "uuid-or-code"
}
```

### Auth

- fonction invocable avec la clé anon
- pas d'utilisateur connecté obligatoire

### Règles métier

1. chercher `friend_invites` par `invite_code`
2. refuser si l'invitation est absente
3. refuser si `status_id != 0`
4. refuser si `expires_at <= now()`
5. retourner seulement les champs utiles à l'UI

### Réponse 200 attendue

```json
{
  "invite_id": "uuid",
  "invite_code": "uuid-or-code",
  "sender_uid": "uuid",
  "sender_name": "Louis",
  "sender_email": "louis@example.com",
  "sender_image": "https://...",
  "receiver_uid": null,
  "receiver_name": null,
  "status_id": 0,
  "created_at": "2026-04-02T10:00:00.000Z",
  "expires_at": "2026-04-09T10:00:00.000Z",
  "source_friend_sid": "uuid",
  "source_friend_name": "Louis-kerry",
  "source_friend_email": "",
  "source_friend_image": "https://..."
}
```

### Erreurs métier recommandées

- `404` invitation introuvable
- `410` invitation expirée
- `409` invitation déjà traitée
- `400` payload invalide

## 6. Edge Function `accept-friend-invite`

### But

Accepter une invitation et rattacher le vrai compte Bicount au `friends.sid` ciblé.

### Entrée

Body JSON:

```json
{
  "invite_code": "uuid-or-code"
}
```

### Auth

- utilisateur connecté obligatoire
- récupérer le receveur avec le JWT de la requête
- ne pas faire confiance à un `receiver_uid` envoyé par le mobile

### Règles métier

1. récupérer `auth.uid()` depuis le JWT
2. chercher l'invitation par `invite_code`
3. refuser si absente
4. refuser si expirée
5. refuser si `status_id != 0`
6. refuser si `source_friend_sid` est vide
7. retrouver la ligne `friends` par `sid = source_friend_sid`
8. refuser si la ligne `friends` n'existe pas
9. refuser si `friends.uid` est déjà renseigné avec un autre utilisateur
10. refuser si `sender_uid = receiver_uid`
11. mettre à jour `friend_invites`:
    - `status_id = 1`
    - `receiver_uid = auth.uid()`
    - idéalement `accepted_at = now()` si cette colonne existe
12. mettre à jour `friends`:
    - `uid = auth.uid()`
13. retourner la ligne finale utile à l'app

### Réponse 200 attendue

```json
{
  "invite_id": "uuid",
  "invite_code": "uuid-or-code",
  "status_id": 1,
  "receiver_uid": "uuid",
  "source_friend_sid": "uuid"
}
```

### Erreurs métier recommandées

- `401` utilisateur non connecté
- `404` invitation absente
- `404` friend source absent
- `409` invitation déjà acceptée ou rejetée
- `409` friend déjà lié à un autre compte
- `422` tentative d'auto-acceptation
- `410` invitation expirée

### Recommandation technique

- exécuter la logique dans une transaction
- utiliser la clé service role dans l'Edge Function
- vérifier explicitement les garde-fous métier avant l'update final

## 7. Contrat mobile attendu

Le mobile va fonctionner ainsi:

1. ouverture du lien `/friend/invite?inviteCode=...`
2. appel Edge Function `friend-invite-preview`
3. affichage de la preview si retour 200
4. si l'utilisateur accepte:
   - vérifier qu'il est connecté
   - vérifier qu'il est en ligne
   - appeler `accept-friend-invite`
5. si succès:
   - laisser le realtime `friend_invites` refléter l'état envoyé/reçu
   - laisser les données `friends` se recharger normalement côté app

Important:

- la preview doit pouvoir marcher sans login
- l'acceptation doit exiger login + connexion Internet

## 8. Contrat de colonnes final côté `friend_invites`

Colonnes attendues:

- `invite_id uuid primary key`
- `invite_code text unique not null`
- `sender_uid uuid not null`
- `sender_name text`
- `sender_email text`
- `sender_image text`
- `receiver_uid uuid null`
- `receiver_name text null`
- `status_id integer not null references public.friend_invites_statut(id) on update no action on delete no action`
- `created_at timestamptz not null`
- `expires_at timestamptz not null`
- `source_friend_sid uuid null`
- `source_friend_name text null`
- `source_friend_email text null`
- `source_friend_image text null`

## 9. A faire avant mise en prod

1. migrer `friend_invites.status` vers `status_id`
2. créer et remplir `friend_invites_statut`
3. déployer `friend-invite-preview`
4. déployer `accept-friend-invite`
5. vérifier les réponses JSON exactes
6. tester:
   - preview sans session
   - acceptation avec session
   - invitation expirée
   - invitation déjà acceptée
   - friend déjà lié

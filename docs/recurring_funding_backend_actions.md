# Backend Actions: Friend Invites + Recurring Fundings

This document consolidates the backend work now expected by the mobile app.

## 1. Friend invite acceptance flow

Salut, pour finaliser proprement le flow d’acceptation d’invitation de profil ami, il faudrait mettre en place les points suivants côté backend.

### 1. Mise à jour de l’invitation acceptée

Lors de l’acceptation d’une invitation :

- récupérer `auth.uid()` du user connecté qui accepte
- retrouver la ligne `friend_invites` via `invite_code`
- vérifier que l’invitation est encore valide
- remplir `friend_invites.receiver_uid = auth.uid()`
- passer `friend_invites.status_id = 1` pour `accepted`

Rappels sur les statuts :

- `0 = pending`
- `1 = accepted`
- `2 = rejected`
- `3 = expired`

### 2. Lier le profil partagé au vrai compte accepté

L’invitation pointe vers un profil ami existant via `source_friend_sid`.

Au moment de l’acceptation, il faut :

- retrouver la ligne `friends` correspondant à `source_friend_sid`
- vérifier qu’elle existe
- vérifier qu’elle n’est pas déjà liée à un autre compte
- mettre `friends.uid = auth.uid()` sur cette ligne

Important :

- ne pas changer `friends.sid`
- ne pas recréer cette ligne source
- `sid` doit rester stable car il est déjà utilisé dans les transactions historiques

### 3. Mettre en place une relation miroir obligatoire

Je veux aussi qu’au moment de l’acceptation, le backend crée la relation miroir côté utilisateur qui accepte.

Concrètement :

- si A partage un profil ami à B
- après acceptation, il ne faut pas seulement lier la ligne `friends` existante de A vers B
- il faut aussi créer une nouvelle ligne `friends` chez B pour représenter correctement A

Cette ligne miroir doit être créée automatiquement côté backend.

### 4. Champs attendus sur la ligne miroir `friends`

Pour cette nouvelle ligne miroir, il faut respecter la structure actuelle de `friends`.

La ligne miroir créée chez l’utilisateur qui accepte doit contenir :

- `sid` : nouveau UUID généré
- `fid` : `auth.uid()` du user qui accepte
- `uid` : `sender_uid` de l’invitation
- `username` : nom du sender
- `email` : email du sender
- `image` : image/avatar du sender
- `relation_type = 0` pour `friend`
- `give = 0`
- `receive = 0`
- `personal_income = null`
- `company_income = null`

Donc en résumé :

- la ligne source existante reste la représentation du profil partagé chez l’émetteur
- la ligne miroir est la représentation de l’émetteur chez le receveur

Important :

- éviter les doublons
- si une ligne miroir équivalente existe déjà pour ce couple, ne pas en recréer une autre

### 5. Recalcul métier attendu après acceptation

Je ne veux pas un calcul de solde figé écrit à la main dans l’Edge Function.

Ce que je veux, c’est que :

- la ligne `friends` source soit bien liée au vrai compte accepté
- la relation miroir soit créée
- les transactions historiques liées à ce profil deviennent lisibles pour le bon utilisateur
- les projections et agrégats se recalculent ensuite normalement à partir des transactions existantes

Objectif métier :

- après acceptation, l’utilisateur accepté doit voir les transactions qui le concernent déjà
- ses soldes et agrégats doivent se reconstruire correctement à partir de ces données

### 6. Accès aux transactions et RLS

Il faut mettre à jour la logique d’accès pour que l’utilisateur accepté puisse lire les transactions où un profil `friends.sid` désormais lié à son `uid` est impliqué.

En pratique :

- si une transaction a `sender_id` ou `beneficiary_id` égal à un `friends.sid`
- et que ce `friends.sid` est désormais lié à `auth.uid()`
- alors l’utilisateur concerné doit pouvoir récupérer cette transaction

Idéalement, cette logique doit s’appuyer sur la relation effective dans `friends`, pas sur `friend_invites`.

### 7. Edge Functions à prévoir

Je veux garder l’approche avec 2 Edge Functions :

#### `friend-invite-preview`

Entrée :

- `inviteCode`

But :

- retourner uniquement les infos nécessaires pour afficher la preview de l’invitation
- sans exposer la table brute publiquement

#### `accept-friend-invite`

Entrée :

- `inviteCode`

But :

- exiger un utilisateur connecté
- mettre à jour `friend_invites`
- lier la ligne `friends` source via `source_friend_sid`
- créer la ligne miroir
- renvoyer un résultat clair de succès ou d’échec

### 8. Vérifications métier à faire dans l’acceptation

La function d’acceptation doit refuser si :

- l’invitation n’existe pas
- l’invitation est expirée
- l’invitation est déjà acceptée
- l’invitation est rejetée
- la ligne `friends` ciblée par `source_friend_sid` n’existe pas
- cette ligne `friends` est déjà liée à un autre `uid`
- le sender essaie d’accepter sa propre invitation
- la relation miroir existe déjà en doublon de manière incohérente

### 9. Résultat final attendu

Après acceptation :

- `friend_invites.receiver_uid` est renseigné
- `friend_invites.status_id = accepted`
- la ligne `friends` source est liée au vrai compte accepté via `friends.uid`
- une ligne miroir `friends` est créée côté receveur avec les bonnes informations du sender
- les transactions historiques deviennent récupérables pour le bon utilisateur
- les agrégats et soldes se recalculent correctement à partir des transactions existantes

## 2. Recurring fundings contract

The mobile app now treats recurring income as a tracking template, not as money that should be counted directly.

Current mobile rule:

- `recurring_fundings` stores the recurring rule only
- actual money must exist as real rows in `account_funding`
- the app no longer auto-generates due `account_funding` rows locally at startup
- when the user explicitly confirms `c'est bon`, mobile creates a normal `account_funding` row
- when the recurring plan is automatic, backend automation must create the real `account_funding` row

## 3. Required behavior for `recurring_fundings`

Keep `recurring_fundings` focused on the recurring template:

- `recurring_funding_id`
- `uid`
- `source`
- `note`
- `amount`
- `currency`
- `funding_type`
- `frequency`
- `start_date`
- `next_funding_date`
- `last_processed_at`
- `status`
- `salary_processing_mode`
- `salary_reminder_status`
- `created_at`

Important:

- do not count `recurring_fundings` directly in balances or analytics
- the app should only count money that exists in `account_funding`

## 4. Required behavior for `account_funding`

`account_funding` must stay the concrete ledger of real received money.

Important contract:

- `funding_id` must remain a real UUID
- do not expect composite values like `uuid-yyyymmdd`
- automatic recurring credits and user-confirmed recurring credits must both land in `account_funding`

Current mobile confirm behavior:

- mobile creates a fresh UUID `funding_id`
- mobile writes the recurring source, amount, currency, funding type, and expected day into that concrete funding row

## 5. Automatic mode must be backend-driven

For plans in automatic mode, do not rely on the mobile app to create due rows anymore.

Recommended implementation:

- use a scheduled Edge Function or cron job
- scan active `recurring_fundings`
- detect which occurrences are due
- create the missing `account_funding` row
- update `next_funding_date` and `last_processed_at`

Important:

- a SQL trigger alone is not enough for time-based execution
- this must be a scheduled backend process

## 6. Idempotence rules

Backend automation must be idempotent.

For one recurring occurrence, do not create duplicate `account_funding` rows.

Minimum safety expected:

- one due occurrence must produce at most one concrete `account_funding`
- rerunning the scheduled job must not duplicate already-created rows

## 7. Temporary matching contract used by mobile

Until a dedicated relational link is added, the mobile app matches recurring occurrences to `account_funding` rows using these fields together:

- `sid`
- `source`
- `funding_type`
- `amount`
- `currency`
- calendar day from `date`

So when backend creates an automatic recurring funding row, it should keep these values aligned with the originating recurring template.

Important:

- `sid` must be the owner user uid
- `source` must stay the recurring source label
- `funding_type` must stay aligned with the recurring template
- `date` should be written on the expected occurrence day

This is the current compatibility contract for the mobile app.

## 8. Recommended future schema improvement

To make recurring occurrence matching exact and future-proof, add optional linkage fields to `account_funding`:

- `recurring_funding_id text null references recurring_fundings(recurring_funding_id)`
- `expected_date date null`
- `generation_mode integer not null default 0`

Recommended enum for `generation_mode`:

- `0 = manual_confirmation`
- `1 = backend_automatic`

Benefits:

- exact match between a recurring template and a concrete funding row
- easier deduplication
- easier auditing
- cleaner mobile UI for received vs pending recurring occurrences

## 9. Realtime

Enable realtime on:

- `public.recurring_fundings`
- `public.account_funding`

This is required so the mobile app can refresh recurring dashboards and balances when:

- a recurring rule changes
- backend automation inserts a concrete recurring funding row
- a second device confirms a recurring payment

## 10. Deep link route for recurring reminders

Recurring payment reminders should now target:

- `/recurring-fundings?recurringFundingId=...&expectedDate=...`

The mobile app still keeps `/salary` as a backward-compatible alias for older links, but new backend payloads should move to `/recurring-fundings`.

## 11. QA checklist

1. Create a recurring funding rule in `recurring_fundings`.
2. Verify that no balance changes happen until a real `account_funding` row exists.
3. Confirm one recurring payment from mobile and verify that a real `account_funding` row is inserted with a UUID `funding_id`.
4. Put one rule in automatic mode and verify that the backend scheduled process creates the missing `account_funding` row.
5. Verify realtime or next-sync propagation on another device.
6. Verify that duplicate automatic rows are not created when the backend job runs twice.

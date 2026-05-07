# Backend Actions: Debt Tracking

Ce document décrit le contrat backend attendu pour le lot `debt`.

Objectif produit :

- garder la création simple dans `ExpenseForm` et `IncomeForm`
- créer un vrai contrat de dette séparé dans `debts`
- garder les flux d'argent réels dans `transactions`
- enregistrer les remboursements uniquement depuis l'écran dédié `/debts`
- ouvrir la gestion dette depuis les cartes analyse, sans ajouter un nouvel onglet principal

Important :

- ce lot ne doit pas provoquer de perte de données lors de la migration locale ou backend
- le contrat cible utilise `origin_id` et `origin_occurrence_date`, plus `recurring_transfert_id` côté mobile visible
- les notifications dette doivent utiliser uniquement `route`

## 1. Table `debts`

Créer une table `public.debts`.

Colonnes recommandées :

- `debt_id uuid primary key`
- `created_by uuid not null references auth.users(id) on delete cascade`
- `lender_id text not null`
- `borrower_id text not null`
- `principal_transaction_id uuid not null unique references public.transactions(tid) on delete cascade`
- `title text not null`
- `note text not null default ''`
- `currency text not null`
- `principal_amount numeric not null`
- `expected_repayment_amount numeric not null`
- `repaid_amount numeric not null default 0`
- `remaining_amount numeric not null`
- `due_date timestamptz not null`
- `status smallint not null default 0`
- `reminder_enabled boolean not null default true`
- `last_due_notification_at timestamptz null`
- `closed_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Décision validée :

- ne pas ajouter de colonne `uid` dans `debts`
- l'identité métier de la dette repose sur `created_by`, `lender_id`, et `borrower_id`
- `lender_id` et `borrower_id` doivent accepter les identités déjà utilisées dans l'app : `users.uid` ou `friends.sid`

## 2. États dette

Aligner le backend sur les états numériques mobiles de `AppDebtState` :

- `0 = active`
- `1 = partial`
- `2 = paid`
- `3 = overdue`
- `4 = cancelled`

Recommandation :

- créer une table de référence `debt_state`
- ou, à défaut, documenter clairement ces valeurs côté SQL et RLS

## 3. Contrat `transactions`

Les flux monétaires réels restent dans `transactions`.

Colonnes attendues :

- `origin_id uuid null`
- `origin_occurrence_date timestamptz null`
- `generation_mode smallint null`

Règles :

- la transaction principale d'une dette reste une vraie ligne `transactions`
- cette ligne principale doit porter `type = 6`
- cette ligne principale doit porter `origin_id = debt_id`
- `origin_occurrence_date` reste `null` pour une dette simple non récurrente
- chaque remboursement enregistré depuis `/debts` crée aussi une vraie ligne `transactions`
- ces lignes de remboursement doivent aussi porter `type = 6` et `origin_id = debt_id`

Important :

- ne plus produire de nouveau code backend qui dépend de `recurring_transfert_id` ou `recurring_occurrence_date`
- pendant la phase de migration, copier d'abord les anciennes valeurs vers `origin_id` et `origin_occurrence_date` avant toute suppression d'ancienne colonne

## 4. Calcul de `remaining_amount`

Décision validée côté mobile :

- `remaining_amount` est recalculé côté front à partir des remboursements réellement enregistrés
- la valeur recalculée est ensuite persistée dans `debts`

Attendu backend :

- ne pas imposer un trigger qui calcule une formule différente de celle du mobile
- si un trigger existe, il doit reproduire exactement la règle mobile
- `remaining_amount` doit rester cohérent avec `expected_repayment_amount - repaid_amount`
- quand `remaining_amount = 0`, `status` doit pouvoir passer à `paid` et `closed_at` être renseigné

## 5. Permissions et RLS

Le backend doit permettre une visibilité cohérente avec l'app.

Minimum attendu :

- le créateur lit et écrit ses dettes
- le prêteur et l'emprunteur liés à un vrai compte doivent pouvoir lire la dette concernée
- la mise à jour d'un remboursement doit rester compatible avec la règle mobile actuelle :
- si les deux côtés sont liés à des comptes réels, seul le prêteur peut confirmer un remboursement reçu
- sinon, seul `created_by` peut mettre à jour la dette

Important :

- le mobile continue d'utiliser des identités mixtes `users.uid` et `friends.sid`
- les policies doivent donc rester compatibles avec cette résolution d'identité au lieu d'imposer un contrat `uid` pur sur `lender_id` et `borrower_id`

## 6. Realtime attendu

Activer le realtime sur :

- `public.debts`
- `public.transactions`
- `public.friends`

Pourquoi :

- les cartes analyse dette doivent se mettre à jour sans refresh manuel
- l'écran `/debts` doit refléter immédiatement un remboursement ou un changement de statut
- la résolution des contreparties reste dépendante de `friends`

## 7. Notifications dette

Le mobile sait déjà naviguer à partir d'un payload `route`.

Contrat attendu :

- ne pas envoyer de logique spéciale côté payload dette
- envoyer uniquement `route`
- exemple recommandé pour ouvrir une dette précise : `/debts?debtId=<debt_id>`
- exemple secondaire possible pour ouvrir un scope : `/debts?scope=receivable` ou `/debts?scope=payable`

Règles :

- ne pas dépendre d'une clé custom `debt_id` seule dans la notification
- si un push backend est envoyé pour une dette due, le `route` doit suffire à l'app pour ouvrir la bonne vue
- les notifications foreground et les taps locaux réutilisent déjà cette logique côté mobile

## 8. Entrée produit côté mobile

Le backend doit rester aligné avec ce flow visible :

- création d'une dette depuis `ExpenseForm` ou `IncomeForm`
- suivi depuis les cartes analyse `À percevoir` et `À rembourser`
- enregistrement d'un remboursement uniquement depuis `/debts`
- aucun nouvel onglet principal pour la dette

## 9. Migration sans perte de données

Règles impératives :

- ne pas supprimer les anciennes colonnes de liaison avant backfill vers `origin_id` et `origin_occurrence_date`
- ne pas réécrire `transactions.tid` ou `debts.debt_id`
- si une migration SQL doit normaliser des colonnes, la stratégie doit être additive puis vérifiée avant cleanup
- garder un chemin de rollback tant que les anciennes colonnes existent encore sur les bases en transition

## 10. Résumé

Backend requis pour ce lot :

- oui pour la table `debts`
- oui pour les policies RLS compatibles avec `created_by`, `lender_id`, `borrower_id`
- oui pour le realtime sur `debts`
- oui pour les notifications route-based vers `/debts?...`
- oui pour une migration additive et sans perte de données sur `origin_*`
- non pour un nouvel onglet ou une surface produit supplémentaire

# Backend Actions: Transaction + Recurring Transfert Unification

Ce document décrit le contrat backend cible pour le prochain lot produit.

Objectif produit :

- garder deux surfaces de création simples côté mobile : `Expense` et `Income`
- absorber les flows `subscription` dans `Expense`
- absorber les flows `add_fund` dans `Income`
- stocker les occurrences réelles dans `transactions`
- stocker les modèles récurrents dans `recurring_transfert`
- classifier les modèles récurrents via `recurring_transfert_type`

Important :

- ce document décrit la cible à mettre en place
- il ne décrit pas l’état actuel de production
- une phase de migration peut exister techniquement, mais la cible validée est la suppression des anciennes tables `subscriptions`, `account_funding`, et `recurring_fundings`

## 1. Décision produit cible

Le mobile garde deux formulaires d’entrée :

- `ExpenseForm` pour toutes les sorties d’argent
- `IncomeForm` pour toutes les entrées d’argent

Les cas métier deviennent :

- `Expense` ponctuel
- `Expense` récurrent type abonnement
- `Expense` récurrent autre
- `Income` ponctuel
- `Income` récurrent type salaire
- `Income` récurrent autre

La création reste séparée par direction du flux, mais le suivi des modèles récurrents doit rester dans une surface dédiée et lisible.

## 2. Contrat cible des tables métier

Tables métier finales attendues pour ce lot :

- `users`
- `friends`
- `transactions`
- `recurring_transfert`
- `recurring_transfert_type`
- `fcm_tokens`
- `notification_events`
- `friend_invites`
- `friend_invites_statut`

Tables à sortir du contrat visible V1 après migration :

- `subscriptions`
- `account_funding`
- `recurring_fundings`

Décision validée :

- ces anciennes tables doivent être supprimées après migration
- le mobile cible ne doit plus dépendre d’elles pour les flows visibles

## 3. Table `recurring_transfert_type`

Créer une table de référence :

- `id smallint primary key`
- `code text unique not null`
- `label text not null`
- `direction smallint not null`
- `is_system boolean not null default true`
- `sort_order smallint not null default 0`

Convention recommandée pour `direction` :

- `0 = expense`
- `1 = income`

Seed minimum recommandé :

- `0 | subscription_expense | Subscription expense | 0`
- `1 | recurring_expense_other | Other recurring expense | 0`
- `2 | salary_income | Salary income | 1`
- `3 | recurring_income_other | Other recurring income | 1`

Règles :

- cette table décrit le type métier du modèle récurrent
- elle ne remplace pas la direction du flux dans l’occurrence réelle
- elle doit rester extensible pour des types futurs sans casser le mobile

## 4. Table `recurring_transfert`

Créer une table qui porte uniquement le modèle récurrent.

Colonnes recommandées :

- `recurring_transfert_id uuid primary key`
- `uid uuid not null references auth.users(id) on delete cascade`
- `transaction_type smallint not null references recurring_transfert_type(id)`
- `title text not null`
- `note text not null default ''`
- `amount numeric not null`
- `currency text not null`
- `sender_id text not null`
- `beneficiary_id text not null`
- `frequency smallint not null`
- `start_date date not null`
- `next_due_date date not null`
- `end_date date null`
- `status smallint not null default 0`
- `execution_mode smallint not null default 0`
- `reminder_enabled boolean not null default true`
- `last_generated_at timestamptz null`
- `last_confirmed_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Convention recommandée :

- `status`: `0 = active`, `1 = inactive`, `2 = archived`
- `execution_mode`: `0 = manual_confirmation`, `1 = backend_automatic`

Règles métier :

- `recurring_transfert` ne doit jamais être compté directement dans les soldes, graphes, revenus, ou dépenses
- cette table ne représente jamais de l’argent réellement compté
- elle représente uniquement une règle de génération ou de confirmation
- si `execution_mode = manual_confirmation`, le backend ne doit pas insérer automatiquement l’occurrence réelle dans `transactions`
- si `execution_mode = backend_automatic`, le backend doit créer l’occurrence réelle dans `transactions` quand elle devient due
- `reminder_enabled` est piloté par l’utilisateur et ne remplace pas `execution_mode`

## 5. Table `transactions`

`transactions` devient le ledger unique des occurrences réelles.

Règle produit :

- toute opération qui impacte vraiment les soldes doit finir dans `transactions`
- il ne doit plus y avoir une autre table visible V1 qui représente une entrée d’argent réelle

Colonnes additionnelles recommandées si elles n’existent pas déjà :

- `recurring_transfert_id uuid null references recurring_transfert(recurring_transfert_id)`
- `recurring_occurrence_date date null`
- `generation_mode smallint null`

Convention recommandée pour `generation_mode` :

- `0 = one_time`
- `1 = recurring_manual_confirmation`
- `2 = recurring_backend_automatic`

Règles métier :

- si `recurring_transfert_id is null`, la transaction est ponctuelle
- si `recurring_transfert_id is not null`, la transaction est une occurrence réelle d’un modèle récurrent
- la transaction réelle doit conserver toutes les données nécessaires aux projections, y compris amount, currency, fx snapshot, category, sender_id, beneficiary_id, date
- les agrégats mobile doivent être recalculés uniquement depuis `transactions` et les autres lignes brutes encore actives dans le contrat final

Décision validée sur `transactions.type` :

- ne pas conserver l’ancien enum hérité de `subscription` / `others`
- redéfinir proprement `transactions.type` autour de la nouvelle cible métier
- la nouvelle définition doit rester cohérente avec la séparation `expense` / `income` et avec l’existence d’occurrences ponctuelles ou issues d’un modèle récurrent

## 6. Règle d’identité sur `sender_id` et `beneficiary_id`

Le contrat mobile actuel doit rester compatible avec AGENTS :

- l’utilisateur courant garde `users.uid` comme identité primaire
- les contreparties sélectionnées dans les formulaires doivent exister dans `friends`
- le côté non-authentifié de l’opération doit se résoudre via `friends.sid`

Règles attendues :

- en `Expense`, le current user est toujours le `sender`
- en `Income`, le current user est toujours le `beneficiary`
- le counterparty choisi dans le formulaire doit exister dans `friends` ou être créé localement puis synchronisé comme aujourd’hui

Important :

- ne pas casser le contrat déjà documenté où des transactions historiques peuvent référencer `friends.sid`
- ne pas remplacer `users.uid` par une identité `friends` canonique pour l’utilisateur connecté sans demande produit explicite

## 7. Règle UI/back pour la récurrence

Le formulaire ne doit pas devenir complexe.

Contrat attendu :

- par défaut, l’utilisateur voit un flow simple ponctuel
- quand il active l’option récurrente, les options avancées apparaissent dynamiquement
- ces options doivent suffire à calibrer le modèle récurrent sans quitter `ExpenseForm` ou `IncomeForm`

Options attendues côté backend pour supporter ce flow :

- type récurrent via `transaction_type`
- fréquence
- date de début
- prochaine échéance
- mode d’exécution (`manual_confirmation` ou `backend_automatic`)
- activation ou non du rappel (`reminder_enabled`)

## 8. Mode manuel vs mode automatique

L’utilisateur choisit le comportement :

- rappel / confirmation manuelle
- génération automatique backend

Règles :

- en mode manuel, le modèle reste dans `recurring_transfert` jusqu’à confirmation explicite de l’occurrence
- en mode manuel, un rappel peut être activé ou non
- en mode automatique, le backend génère l’occurrence réelle dans `transactions`
- en mode automatique, il ne doit pas y avoir de doublon si le job tourne deux fois

Recommandation scalable :

- conserver un écran séparé de suivi des récurrents
- utiliser ce même écran pour lister les modèles, leur prochain due date, leur mode, et l’état des confirmations manuelles
- ne pas remettre toute la complexité de suivi dans le formulaire de création

## 9. Realtime attendu

Activer le realtime sur :

- `public.transactions`
- `public.recurring_transfert`
- `public.friends`

Pourquoi :

- les occurrences réelles doivent rafraîchir immédiatement les soldes et graphes
- les modèles récurrents doivent rafraîchir l’écran de suivi et les détails de configuration
- la résolution des parties `friends` doit rester cohérente sur plusieurs appareils

## 10. RLS attendu

Le backend doit garder des policies lisibles pour les tables cibles.

Minimum attendu :

- l’utilisateur lit et écrit ses propres lignes `recurring_transfert`
- l’utilisateur lit les `transactions` où il est owner ou impliqué selon la logique déjà documentée autour de `users.uid` et `friends.sid`
- l’utilisateur lit les `friends` qui lui appartiennent selon le contrat existant

Important :

- le contrat de lecture des transactions liées à des `friends.sid` déjà documenté dans les autres mémos doit rester valide
- ne pas rétrécir les accès au point de casser la réhydratation cross-device ou les projections locales

## 11. Automatisation backend

Le mode automatique nécessite un vrai traitement planifié côté backend.

Recommandation :

- job planifié / cron / Edge Function schedulée

Responsabilités :

- scanner les `recurring_transfert` actifs en mode automatique
- détecter les occurrences dues
- créer la ligne réelle dans `transactions`
- mettre à jour `next_due_date`
- renseigner `last_generated_at`
- garantir l’idempotence

Le backend ne doit pas :

- compter directement les modèles récurrents dans les agrégats
- générer plusieurs occurrences identiques pour la même échéance
- conserver une logique séparée qui continuerait à alimenter `subscriptions` ou `account_funding` pour le flux visible V1

## 12. Migration des anciennes tables vers la cible

### `subscriptions` -> `recurring_transfert`

Migrer les abonnements vers `recurring_transfert` avec :

- `transaction_type = subscription_expense`
- `execution_mode` selon le choix produit ou le comportement actuel par défaut
- `sender_id = current user uid`
- `beneficiary_id = friend sid` ou identifiant métier déjà utilisé pour la contrepartie

### `recurring_fundings` -> `recurring_transfert`

Migrer les revenus récurrents vers `recurring_transfert` avec :

- `salary_income` pour les salaires
- `recurring_income_other` pour les autres entrées récurrentes

### `account_funding` -> `transactions`

Les anciennes entrées réelles doivent devenir des `transactions` de type income si elles doivent rester visibles dans le flux unifié.

Important :

- vérifier la migration des données FX et des snapshots
- conserver les dates réelles des occurrences
- ne pas perdre la distinction entre occurrence ponctuelle et occurrence issue d’un modèle récurrent quand cette information existe
- supprimer ensuite physiquement `account_funding` du contrat cible

## 13. Projection et calculs offline

Avec cette cible, les calculs visibles doivent devenir plus simples :

- les dépenses et revenus réels se projettent depuis `transactions`
- les modèles récurrents se lisent depuis `recurring_transfert`
- les modèles récurrents n’impactent jamais les soldes avant occurrence réelle

Le backend doit donc éviter :

- toute logique legacy qui continuerait à traiter `account_funding` comme ledger primaire du V1 visible
- toute logique legacy qui continuerait à traiter `subscriptions` comme source canonique des charges récurrentes

## 14. Proposition scalable côté architecture produit

Meilleure structure recommandée pour rester scalable :

- `ExpenseForm`: création simple + panneau récurrent conditionnel
- `IncomeForm`: création simple + panneau récurrent conditionnel
- écran séparé de suivi récurrent : consultation, pause, reprise, changement de mode, prochaines échéances, confirmations manuelles

Pourquoi cette structure est meilleure :

- création simple et rapide
- pas de surface monolithique mélangeant tout
- séparation claire entre création et supervision
- extensible si plus tard on ajoute d’autres types récurrents sans refaire toute l’UI

## 15. Checklist QA backend

1. Créer une expense ponctuelle et vérifier qu’elle tombe dans `transactions`.
2. Créer une income ponctuelle et vérifier qu’elle tombe dans `transactions`.
3. Créer une charge récurrente type abonnement et vérifier qu’elle tombe dans `recurring_transfert` avec le bon `transaction_type`.
4. Créer une entrée récurrente type salaire et vérifier qu’elle tombe dans `recurring_transfert` avec le bon `transaction_type`.
5. Vérifier qu’aucun modèle récurrent n’impacte les soldes tant qu’aucune occurrence réelle n’existe.
6. Vérifier qu’un mode manuel crée une occurrence réelle uniquement après confirmation explicite.
7. Vérifier qu’un mode automatique crée l’occurrence réelle via le job backend sans doublon.
8. Vérifier que `friends` reste compatible avec les résolutions `sender_id` / `beneficiary_id` attendues par le mobile.
9. Vérifier le realtime sur `transactions`, `recurring_transfert`, et `friends`.

## 16. Décisions validées le 2026-04-09

Décisions produit / backend confirmées :

- les anciennes tables `subscriptions`, `account_funding`, et `recurring_fundings` doivent être supprimées après migration
- `transactions.type` doit être redéfini proprement autour de la nouvelle cible métier, et ne doit pas conserver l’ancien découpage historique
- il n’est pas nécessaire de stocker un snapshot de `transaction_type` dans `transactions`; le lien `recurring_transfert_id` suffit pour l’architecture cible

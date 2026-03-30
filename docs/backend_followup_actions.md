# Backend Follow-Up Actions

Ce document regroupe les actions backend nécessaires pour le lot suivant :

- états métier numériques centralisés
- édition et désabonnement des abonnements
- récupération correcte des données sur un autre appareil

Les points `recherche transaction` et `traduction des catégories` sont purement mobiles.

## 1. Tables d’état

### `subscription_state`

Créer une table :

- `id smallint primary key`
- `code text unique not null`
- `label text not null`

Lignes minimales :

- `0 | subscribed | Subscribed`
- `1 | unsubscribed | Unsubscribed`

### `recurring_funding_state`

Créer une table :

- `id smallint primary key`
- `code text unique not null`
- `label text not null`

Lignes minimales :

- `0 | active | Active`
- `1 | inactive | Inactive`

## 2. Migration des colonnes `status`

### `subscriptions`

Vérifier ou ajouter :

- `status smallint not null default 0`
- `end_date timestamptz null`

FK recommandée :

- `subscriptions.status references subscription_state(id)`

Migration recommandée :

- `0 -> 0`
- `1 -> 1`
- `2 -> 1`
- `null -> 0`

### `recurring_fundings`

Vérifier ou ajouter :

- `status smallint not null default 0`

FK recommandée :

- `recurring_fundings.status references recurring_funding_state(id)`

Migration recommandée :

- `0 -> 0`
- `1 -> 1`
- `2 -> 1`
- `null -> 0`

## 3. Désabonnement et édition des abonnements

Le mobile envoie maintenant de vrais updates sur `subscriptions`.

Le backend doit autoriser la mise à jour de :

- `status`
- `end_date`
- `next_billing_date`
- `title`
- `amount`
- `currency`
- `frequency`
- `notes`
- `start_date`
- `category`
- `reference_currency_code`
- `converted_amount`
- `amount_cdf`
- `rate_to_cdf`
- `fx_rate_date`
- `fx_snapshot_id`

Quand l’utilisateur se désabonne :

- `status` doit passer à `1`
- `end_date` doit être renseigné

## 4. Lecture multi-appareils

Le correctif principal a été fait côté mobile :

- l’app force maintenant une hydratation distante initiale avant de s’appuyer sur les streams temps réel

Le backend doit rester aligné sur ces tables :

- `users`
- `friends`
- `transactions`
- `subscriptions`
- `account_funding`
- `recurring_fundings`

### Vérifications à faire

- les policies RLS doivent autoriser la lecture des lignes de l’utilisateur courant
- les tables finance doivent être présentes dans la publication Realtime si vous attendez des updates live
- `users.uid` reste la clé d’identité principale du compte connecté

## 5. SQL de seed recommandé

```sql
insert into subscription_state (id, code, label)
values
  (0, 'subscribed', 'Subscribed'),
  (1, 'unsubscribed', 'Unsubscribed')
on conflict (id) do update
set code = excluded.code,
    label = excluded.label;

insert into recurring_funding_state (id, code, label)
values
  (0, 'active', 'Active'),
  (1, 'inactive', 'Inactive')
on conflict (id) do update
set code = excluded.code,
    label = excluded.label;
```

## 6. Résumé

Backend requis pour ce lot :

- oui pour les tables d’état et la migration des colonnes `status`
- oui pour vérifier les droits de lecture cross-device et le realtime finance
- non pour la recherche transaction
- non pour la localisation des catégories

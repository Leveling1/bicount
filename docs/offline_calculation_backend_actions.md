# Offline Calculation Backend Actions

This memo describes the backend alignment needed now that Bicount calculates the main finance aggregates locally in the mobile app.

## Product Decision

The mobile app now computes the visible finance totals locally instead of relying on Supabase triggers as the primary source of truth.

Affected aggregate fields:

- `users.balance`
- `users.incomes`
- `users.expenses`
- `users.personal_income`
- `users.company_income`
- `friends.give`
- `friends.receive`
- `friends.personal_income`
- `friends.company_income`
- `companies.profit`

## What The App Now Does

The app applies the finance formulas locally when the user creates:

- a transaction
- an account funding
- a subscription

The app also projects visible user and friend totals locally from raw synced rows:

- `transactions`
- `account_funding`
- `friends`
- `users`

This projection is used in the `main` flow so another device can still display correct totals after sync, even if the backend no longer mutates aggregate columns automatically.

## Backend Guidance

### 1. Stop treating aggregate columns as canonical

If backend triggers currently update the aggregate fields above, they should no longer be treated as the source of truth for the mobile UI.

Preferred direction:

- keep raw finance rows authoritative
- let the app compute visible totals locally

### 2. If backend triggers remain temporarily

If you keep triggers for a transition period, make sure they exactly match the same formulas used by the app.

They must not introduce:

- extra adjustments
- duplicate side effects
- different category handling
- different subscription side effects

### 3. Keep raw tables healthy and realtime-enabled

The app now depends more strongly on the correctness of raw synchronized rows.

Important tables:

- `transactions`
- `account_funding`
- `subscriptions`
- `friends`
- `users`

Recommended:

- keep RLS correct for row access
- keep realtime enabled where the app already expects it
- avoid backend jobs that rewrite aggregate columns in ways that can race with mobile sync

### 4. Subscription backend behavior

The current mobile flow creates:

- the `subscriptions` row
- the subscription-backed `friends` row
- the generated `transactions` row

If backend automation still performs any of these actions, it must not create duplicates.

## Operational Recommendation

For the V1 mobile flow, treat raw rows as authoritative and aggregate columns as compatibility fields only.

If you later want server-side reporting again, introduce it as a separate reporting projection instead of coupling the mobile UI back to trigger-maintained totals.

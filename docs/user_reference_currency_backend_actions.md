# User Reference Currency Backend Action

This note covers the extra backend change needed so the user's preferred reference currency follows them across devices.

## Required Change

Add one nullable column to `public.users`:

- `reference_currency_code text references public.currencies(code)`

Recommended default:

- `CDF`

If you prefer not to use a database default, the mobile app already falls back to `CDF` when the value is missing.

## Expected Behavior

- when the user selects a new reference currency in settings, the mobile app updates `users.reference_currency_code`
- when the same user signs in on another device, the app reads `users.reference_currency_code` and restores that preference automatically
- local cache remains only a fallback for bootstrap and offline continuity

## RLS Guidance

Keep the same ownership rule as the rest of the user profile:

- authenticated user can read their own row
- authenticated user can update their own row
- no user may update another user's row

## SQL Sketch

```sql
alter table public.users
add column if not exists reference_currency_code text
references public.currencies(code);
```

Optional backfill:

```sql
update public.users
set reference_currency_code = 'CDF'
where reference_currency_code is null;
```

## Mobile Contract

The app assumes:

- the column exists on `users`
- the value is either null or a valid `currencies.code`
- if null, the app uses `CDF`

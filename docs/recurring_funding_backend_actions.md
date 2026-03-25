# Recurring Funding Backend Actions

This note describes the backend alignment required for the new recurring income flow used by `Add funds`.

## Goal

The mobile app now supports:

- one-time account funding
- recurring income templates such as salary
- local generation of real `account_funding` rows when a recurring income becomes due

Important:

- recurring income generation is now handled locally in the mobile app
- Supabase should store the recurring templates and the generated funding rows
- backend triggers must not double-create the same recurring funding occurrences

## Required schema changes

### 1. Extend `account_funding`

Add a `funding_type` column so actual funding rows can distinguish salary from other income.

Recommended contract:

- `funding_type = 0` -> salary
- `funding_type = 1` -> other income

Suggested SQL:

```sql
alter table public.account_funding
add column if not exists funding_type integer not null default 1;
```

### 2. Create `recurring_fundings`

Create a table used for recurring income templates.

Suggested columns:

- `recurring_funding_id text primary key`
- `uid uuid not null references auth.users(id) on delete cascade`
- `source text not null`
- `note text null`
- `amount numeric not null`
- `currency text not null`
- `funding_type integer not null default 1`
- `frequency integer not null`
- `start_date timestamptz not null`
- `next_funding_date timestamptz not null`
- `last_processed_at timestamptz null`
- `status integer not null default 0`
- `created_at timestamptz not null default now()`

Recommended enums used by the app:

- `funding_type = 0` -> salary
- `funding_type = 1` -> other income
- `status = 0` -> active
- `status = 1` -> paused
- `status = 2` -> cancelled
- `frequency = 0` -> weekly
- `frequency = 1` -> monthly
- `frequency = 2` -> quarterly
- `frequency = 3` -> yearly

## RLS

The mobile app assumes the authenticated user only accesses its own recurring income templates.

Recommended policies on `public.recurring_fundings`:

- `select`: `uid = auth.uid()`
- `insert`: `uid = auth.uid()`
- `update`: `uid = auth.uid()`
- `delete`: `uid = auth.uid()`

For `public.account_funding`, keep the existing personal rule aligned with the current contract:

- personal rows use `sid = auth.uid()`

## Realtime

Enable realtime on:

- `public.account_funding`
- `public.recurring_fundings`

This keeps multi-device sync coherent when a recurring funding template is changed on one device and consumed on another.

## Important backend rule

Do not add a Supabase trigger that automatically creates recurring funding occurrences from `recurring_fundings`.

Why:

- the mobile app already creates due occurrences locally
- adding a trigger would risk duplicate `account_funding` rows
- the app uses deterministic `funding_id` values for generated occurrences and expects them to stay unique

If backend-side automation is added later, it must exactly mirror the mobile deduplication contract first.

## Recommended SQL extras

### Unique ids

```sql
create unique index if not exists recurring_fundings_uidx
on public.recurring_fundings(recurring_funding_id);

create index if not exists recurring_fundings_uid_idx
on public.recurring_fundings(uid);
```

## Mobile behavior summary

The app now behaves like this:

1. user creates a recurring income template in `recurring_fundings`
2. on app startup, and right after creation, mobile checks all due templates
3. for each due occurrence, mobile inserts a real `account_funding` row
4. mobile updates `next_funding_date` to the next occurrence
5. `Home`, `Graphs`, and balance projections react from local data

## QA checklist for backend

1. Create one recurring funding row for a user.
2. Verify the row is selectable with RLS enabled.
3. Verify the same user can update `next_funding_date`, `last_processed_at`, and `status`.
4. Verify another user cannot read or modify that row.
5. Verify generated `account_funding` rows accept the new `funding_type` column.

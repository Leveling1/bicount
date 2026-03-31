# Salary Tracking Backend Actions

This note describes the backend alignment required for Bicount's dedicated salary tracking flow.

The mobile app now distinguishes:

- an expected salary payment
- a confirmed salary payment
- arrears still owed by the employer

Important product rule:

- a salary that requires confirmation must **not** create a real `account_funding` row until the user confirms the payment was received

## Goal

Support a salary flow where:

- the user creates a recurring salary template
- Bicount can remind the user on payday
- the user can confirm the payment or keep the old automatic process
- unpaid salary dates remain visible as arrears

## Current mobile contract

The mobile app uses `recurring_fundings` as the source of truth for salary plans.

It derives salary occurrences locally from:

- the recurring salary schedule
- the deterministic occurrence id
- the presence or absence of the matching `account_funding` row

Deterministic occurrence funding id contract:

- `funding_id = {recurring_funding_id}-{yyyyMMdd}`

Example:

- recurring funding id: `abc-123`
- expected salary date: `2026-03-31`
- generated/confirmed funding id: `abc-123-20260331`

Because of this contract:

- if the matching `account_funding` row exists, the occurrence is considered received
- if it does not exist and the date is past, the occurrence is considered overdue
- if it does not exist and the date is today, the occurrence is due today

## Required schema changes

### 1. Extend `public.recurring_fundings`

Add salary-specific behavior columns:

- `salary_processing_mode integer not null default 1`
- `salary_reminder_status integer not null default 0`

Recommended values used by the mobile app:

- `salary_processing_mode = 0` -> confirmation required
- `salary_processing_mode = 1` -> automatic
- `salary_reminder_status = 0` -> enabled
- `salary_reminder_status = 1` -> disabled

Suggested SQL:

```sql
alter table public.recurring_fundings
add column if not exists salary_processing_mode integer not null default 1;

alter table public.recurring_fundings
add column if not exists salary_reminder_status integer not null default 0;
```

### 2. Keep `public.account_funding` as the confirmed-money table

No separate salary occurrence row is required by the current mobile implementation.

Confirmed salary payments continue to be stored in:

- `public.account_funding`

Existing `funding_type` contract remains:

- `funding_type = 0` -> salary
- `funding_type = 1` -> other income

## Backend notification responsibility

The backend is responsible for reliable payday notifications.

Recommended behavior:

1. find active recurring salary templates where:
   - `funding_type = 0`
   - `status = 0`
   - `salary_processing_mode = 0`
   - `salary_reminder_status = 0`
2. compute whether today matches the expected salary date
3. verify the matching `account_funding.funding_id` does not already exist
4. send a push notification asking whether the salary was received

Recommended notification payload:

- `route = /salary?recurringFundingId={id}&expectedDate={yyyy-MM-dd}`
- title example: `Salary due today`
- body example: `Did you receive your salary from {source}?`

Important:

- the backend should send the reminder
- the mobile app will handle the confirmation action
- the backend should **not** auto-insert a confirmed salary payment for `salary_processing_mode = 0`

## Automatic mode rule

If the user chooses:

- `salary_processing_mode = 1`
- and typically `salary_reminder_status = 1`

then the old automatic behavior continues:

- mobile can create the concrete `account_funding` row when the recurring salary becomes due
- no confirmation reminder is required

## RLS

Recommended policies on `public.recurring_fundings`:

- `select`: `uid = auth.uid()`
- `insert`: `uid = auth.uid()`
- `update`: `uid = auth.uid()`
- `delete`: `uid = auth.uid()`

For `public.account_funding`, keep the existing rule:

- personal rows use `sid = auth.uid()`

## Realtime

Enable realtime on:

- `public.recurring_fundings`
- `public.account_funding`

This is required so:

- salary plan mode changes sync across devices
- confirmed salary payments appear on another device
- arrears and due-today states stay coherent

## What the backend must not do

Do **not** create a trigger that always inserts salary payments into `account_funding`.

Why:

- confirmation-mode salaries must stay unpaid until the user confirms them
- auto-inserting would destroy the arrears view
- it would also conflict with the deterministic funding id contract

## Optional observability

If you want better server-side monitoring, you can log payday reminder dispatches in an internal table such as:

- `salary_notification_events`

This is optional for the mobile contract.

Suggested columns:

- `id uuid primary key default gen_random_uuid()`
- `recurring_funding_id text not null`
- `expected_date date not null`
- `sent_at timestamptz not null default now()`
- `status integer not null default 0`

Possible statuses:

- `0` -> sent
- `1` -> opened
- `2` -> failed

## QA checklist

1. Create a recurring salary with:
   - `funding_type = 0`
   - `salary_processing_mode = 0`
   - `salary_reminder_status = 0`
2. Verify the row is readable only by the owner.
3. Verify the backend can compute that today's date is due.
4. Verify a push notification can target `/salary?recurringFundingId=...&expectedDate=...`.
5. Verify no `account_funding` row is inserted until mobile confirms.
6. Confirm the salary from mobile and verify the matching `funding_id` is created.
7. Switch the salary to automatic mode and verify future due dates return to the old automatic behavior.

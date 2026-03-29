# Settings backend actions

This document lists the backend work required for the Bicount `settings` feature added in V1.

## What the mobile app now does

The new settings flow can:

- request access to `Bicount Pro`
- edit the visible profile locally through Brick sync
- change theme locally
- change language locally
- sign out
- request account deletion after confirmation and a bottom-sheet reason form

Only the following parts require backend support:

- `pro_upgrade_requests`
- `account_deletion_requests`
- Edge Function `delete-account`

Theme and language do not require backend work.

## Table 1: pro_upgrade_requests

Expected columns:

- `request_id uuid primary key`
- `user_uid uuid not null references auth.users(id)`
- `contact_email text not null`
- `organization_name text not null`
- `use_case text not null`
- `status text not null default 'pending'`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Recommended statuses:

- `pending`
- `reviewed`
- `approved`
- `rejected`

Recommended constraint:

- unique active request per user if that matches product policy

Suggested RLS:

- authenticated user can `insert` only for their own `user_uid`
- authenticated user can `select` only their own rows
- direct `update/delete` from client should usually be denied
- admin/service role manages status changes

## Table 2: account_deletion_requests

Expected columns:

- `request_id uuid primary key`
- `user_uid uuid not null references auth.users(id)`
- `reason_code text not null`
- `details text not null default ''`
- `status text not null default 'submitted'`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Recommended statuses:

- `submitted`
- `processing`
- `deleted`
- `rejected`

Suggested RLS:

- authenticated user can `insert` only for their own `user_uid`
- authenticated user can `select` only their own rows if needed
- client should not directly delete rows
- admin/service role manages lifecycle updates

## Edge Function: delete-account

The app calls:

- `supabase.functions.invoke('delete-account', body: {...})`

Expected payload:

- `request_id`
- `user_uid`
- `reason_code`
- `details`

Minimum required behavior:

1. verify the caller matches `user_uid`
2. verify the corresponding `account_deletion_requests` row exists
3. mark the request as `processing` or keep it `submitted`
4. return a success payload so the mobile app can sign the user out

Preferred behavior:

1. verify auth
2. persist an audit trail
3. revoke or clean user-owned domain data according to policy
4. delete or anonymize `auth.users` record if product/legal policy allows it
5. update `account_deletion_requests.status` to `deleted` or `rejected`

If full deletion is not ready yet:

- keep the function as a safe stub that records the request and returns success
- do not make the app wait on a manual back-office process

## Mobile write patterns

### Pro request

The app inserts/upserts:

- table: `pro_upgrade_requests`
- values:
  - `request_id`
  - `user_uid`
  - `contact_email`
  - `organization_name`
  - `use_case`
  - `created_at`
  - `status = 'pending'`

### Account deletion request

The app inserts/upserts:

- table: `account_deletion_requests`
- values:
  - `request_id`
  - `user_uid`
  - `reason_code`
  - `details`
  - `created_at`
  - `status = 'submitted'`

Then it invokes the Edge Function `delete-account`.

## Reason codes currently sent by the app

- `missing_features`
- `too_expensive`
- `privacy`
- `too_complex`
- `not_useful`
- `other`

The backend should accept these exact values.

## No backend action required

These settings actions are local or already covered by existing flows:

- theme preference
- language preference
- sign out
- profile edit display name/avatar through existing `users` sync

## Recommended implementation order

1. create `pro_upgrade_requests`
2. create `account_deletion_requests`
3. add RLS policies
4. implement `delete-account`
5. test from a real mobile session

## Release note

This file was added for the new `settings` feature. Any future change to the settings backend contract should also update:

- `AGENTS.md`
- this file

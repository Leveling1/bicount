# Bicount V1 - Supabase handoff

## Scope

This document covers the backend work required to support the current Bicount V1 mobile app as implemented in the Flutter codebase on March 18, 2026.

V1 assumptions:
- mobile only: Android and iOS
- `company`, `group`, and `project` remain in source but are hidden from the released user flow
- visible navigation is now `Home / Graphs / Transaction / Profile`
- friend sharing uses invitation links and QR codes
- notifications use `FCM + local reminders`
- the app remains offline-first and realtime where backend support exists

## Already documented in the current backend PDF

The backend technical document already describes these existing tables:
- `users`
- `companies`
- `company_with_user_link`
- `groups`
- `projects`
- `transactions`
- `friends`
- `subscriptions`
- `account_funding`
- `memoji`

The document also describes these existing database functions and flows:
- `update_user_balances`
- `add_funds_to_the_balance`
- `add_subscriptions_to_the_balance`
- edge functions around company, group, project, and subscription processing

These existing resources should stay in place for V1.

## New backend work required for V1

### 1. `friend_invites` table

Create a new table named `friend_invites`.

Recommended columns:

```sql
create table public.friend_invites (
  invite_id uuid primary key default gen_random_uuid(),
  invite_code text not null unique,
  sender_uid uuid not null references auth.users(id) on delete cascade,
  sender_name text,
  sender_email text,
  sender_image text,
  receiver_uid uuid references auth.users(id) on delete set null,
  receiver_name text,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  updated_at timestamptz not null default now()
);
```

Status values expected by the app:
- `pending`
- `accepted`
- `rejected`
- `expired`

Recommended constraints:
- unique on `invite_code`
- check on valid `status`

### 2. `device_tokens` table

Create a new table named `device_tokens`.

Recommended columns:

```sql
create table public.device_tokens (
  token_id uuid primary key default gen_random_uuid(),
  user_uid uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
```

Expected `platform` values:
- `android`
- `iOS`

### 3. `notification_events` table

Create a new table named `notification_events`.

Recommended columns:

```sql
create table public.notification_events (
  event_id uuid primary key default gen_random_uuid(),
  user_uid uuid not null references auth.users(id) on delete cascade,
  category text not null,
  title text not null,
  body text,
  route text,
  payload jsonb not null default '{}'::jsonb,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);
```

Categories currently expected by the app:
- `friend_invite`
- `friend_accept`
- `transaction_created`
- `subscription_due`
- `subscription_changed`

## RLS policies

### `friend_invites`

Minimum required behavior:
- a user can read invites they sent
- a user can read invites they received
- a user can insert invites where `sender_uid = auth.uid()`
- a user can update an invite they received when accepting or rejecting

Recommended policies:

```sql
create policy "friend_invites_select_own"
on public.friend_invites
for select
to authenticated
using (sender_uid = auth.uid() or receiver_uid = auth.uid());

create policy "friend_invites_insert_own"
on public.friend_invites
for insert
to authenticated
with check (sender_uid = auth.uid());

create policy "friend_invites_update_sender_or_receiver"
on public.friend_invites
for update
to authenticated
using (sender_uid = auth.uid() or receiver_uid = auth.uid())
with check (sender_uid = auth.uid() or receiver_uid = auth.uid());
```

### `device_tokens`

Minimum required behavior:
- a user can insert and update only their own device tokens
- a user can read only their own device tokens

### `notification_events`

Minimum required behavior:
- a user can read only their own notification events
- insert should be done by service role or trusted server function

## Required RPC / function

### `accept_friend_invite`

The Flutter app already tries to call an RPC named `accept_friend_invite`.

It should:
1. find the invite by `invite_code`
2. reject if invite is missing, expired, or not pending
3. set `receiver_uid`
4. set `status = 'accepted'`
5. create a row in the existing `friends` table
6. optionally create the reverse friend row too if your current data model expects bidirectional records
7. enqueue a notification event for the sender

Recommended signature:

```sql
accept_friend_invite(
  p_invite_code text,
  p_receiver_uid uuid
)
```

### Suggested helper function

Create a scheduled job or SQL function to mark stale pending invites as `expired`.

## Realtime configuration

Enable realtime on:
- `friend_invites`
- `friends`
- `transactions`
- `subscriptions`
- `account_funding`

V1 uses realtime for:
- friend invite updates
- accepted friend list updates
- graph refresh from transactions, subscriptions, and account funding

## Push notifications via FCM

### Required server-side behavior

Create an Edge Function dedicated to FCM sending.

Suggested name:
- `send_push_notification`

The function should:
1. receive `user_uid`, `title`, `body`, `category`, optional `route`, optional `payload`
2. resolve all tokens from `device_tokens`
3. send an FCM notification to all active tokens
4. write a row to `notification_events`
5. optionally remove invalid tokens returned by FCM

### FCM payload shape expected by the app

Recommended payload:

```json
{
  "category": "friend_invite",
  "title": "New invitation",
  "body": "Louis invited you on Bicount",
  "route": "/friend/invite?code=abc123",
  "invite_code": "abc123"
}
```

## When to notify

### Friend flow
- when a new invite is created: notify the receiver if known later or when invite is opened
- when an invite is accepted: notify the sender
- when an invite is rejected: optional, sender notification can be added later

### Transaction flow
- when a shared transaction materially affects another user: notify impacted friends

### Subscription flow
- when a subscription is created or updated: optional push
- local reminders are already scheduled on device by the app
- backend push for subscription due is optional but useful when the user has multiple devices

## App links / deep links

The Flutter app currently uses this base URL in code:
- `https://preview.bicount.app`

Expected invite path:
- `/friend/invite?code=<invite_code>`

Backend / infra actions required:
- host the HTTPS domain
- publish Android asset links for the package name
- publish iOS apple-app-site-association
- keep the same route contract

If the final domain changes, update the Flutter environment variable:
- `BICOUNT_INVITE_BASE_URL`

## Order of execution recommended

1. Create `friend_invites`
2. Create `device_tokens`
3. Create `notification_events`
4. Add RLS policies
5. Implement `accept_friend_invite`
6. Enable realtime on new tables
7. Implement FCM Edge Function
8. Configure app links domain files
9. Validate with two real devices

## Notes on current V1 app behavior

- The app caches friend share links locally, so link generation still works offline.
- Acceptance and remote invite sync require the backend pieces above.
- Notification reminders for subscriptions are already handled locally on device.
- `company`, `group`, and `project` backend resources are intentionally unchanged for this V1 release.

## 2026-03-19 update - linking a local friend to a real Bicount account

The invite flow is now friend-specific.

New product behavior:

- a `friend` can be created locally and used in transactions before that person owns a Bicount account
- newly created placeholder friends are now stored with `uid = null`
- for backward compatibility, the mobile app also treats `uid = sid` with `fid = owner uid` as an unlinked local friend
- the share action only appears for unlinked friends from the friend detail screen

Required backend delta:

- `friend_invites` must now target an exact row in `public.friends`
- add the following columns to `friend_invites`:
  - `source_friend_sid text not null`
  - `source_friend_name text`
  - `source_friend_email text`
  - `source_friend_image text`

When an invite is accepted, the backend must:

1. resolve the invite from `invite_code`
2. validate that it is still pending and not expired
3. fill `receiver_uid`
4. mark the invite as `accepted`
5. update `public.friends.uid` for the row identified by `source_friend_sid` with the real account `uid` of the accepting user

The new dedicated friend list screen is `lib/features/friend/presentation/screens/friends_directory_screen.dart`, and realtime friend detail is derived through `lib/features/friend/domain/services/friend_view_service.dart`.

### Device token uniqueness update

The mobile app now maintains a single active row per `user_uid` in `device_tokens`.

Recommended hardening on Supabase:

```sql
create unique index if not exists device_tokens_user_uid_unique
on public.device_tokens(user_uid);
```

Behavior expected by the app:

- if `user_uid` already exists: update the existing row
- if `user_uid` does not exist: insert a new row
- if duplicates already exist for the same `user_uid`: keep one row and remove the others

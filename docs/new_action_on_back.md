# new_action_on_back

## Purpose

This document is the short backend delta for the current Bicount V1 mobile build.
It focuses only on what still has to be done on Supabase so the current app behavior works correctly.

Reference date:
- 2026-03-19

Already done on backend side:
- uniqueness on `public.fcm_tokens.user_uid` is already in place

This means the remaining work is mainly about:
- friend profile linking
- secure invite loading and decision flow
- realtime propagation
- push event orchestration

## Current app behavior to support

The mobile app now works like this:
- a `friend` can exist locally before the person has a real Bicount account
- that local friend is stored in `public.friends` with a stable `sid`
- in this state, `friends.uid` is `null`
- the user can already create transactions with that friend
- later, the owner shares that exact friend profile by QR code or HTTPS link
- when the invited person signs in and accepts, the backend must link the existing `friends` row to the real account by updating `friends.uid`
- the app expects this change to arrive in realtime so the detail page and friend list update immediately

Important invariant:
- do not change `friends.sid` during linking
- transactions are already attached to that friend identity through the existing row
- the correct behavior is to update the existing row, not to replace it with a new one

## Actions still required on backend

### 1. Verify or add the targeting columns on `friend_invites`

The invite is no longer a generic invite.
It must target one exact row in `public.friends`.

Required columns on `public.friend_invites`:
- `source_friend_sid text not null`
- `source_friend_name text`
- `source_friend_email text`
- `source_friend_image text`

If they are missing, add them:

```sql
alter table public.friend_invites
  add column if not exists source_friend_sid text,
  add column if not exists source_friend_name text,
  add column if not exists source_friend_email text,
  add column if not exists source_friend_image text;

update public.friend_invites
set source_friend_sid = invite_id::text
where source_friend_sid is null;

alter table public.friend_invites
  alter column source_friend_sid set not null;
```

Recommended extra index:

```sql
create index if not exists friend_invites_source_friend_sid_idx
on public.friend_invites(source_friend_sid);
```

### 2. Implement the linking logic in `accept_friend_invite`

This RPC is the most important backend action.
The mobile app already tries to call it.

Expected signature:

```sql
accept_friend_invite(
  p_invite_code text,
  p_receiver_uid uuid
)
```

Expected behavior:
1. find the invite by `invite_code`
2. lock the row for update
3. reject if the invite is missing, expired, or not `pending`
4. set `receiver_uid = p_receiver_uid`
5. optionally set `receiver_name`
6. set `status = 'accepted'`
7. set `updated_at = now()`
8. find the targeted row in `public.friends` using `source_friend_sid`
9. update only that row by setting `uid = p_receiver_uid`
10. do not change `sid`
11. do not create a replacement friend row for the sender side
12. create a `notification_events` row for the sender
13. optionally trigger push delivery to the sender

Recommended safety checks:
- ensure `source_friend_sid` exists in `public.friends`
- ensure the targeted row still belongs to the sender side of the relation
- prevent accepting the same invite twice
- prevent linking a second different user if `friends.uid` is already filled with another value

Minimal SQL skeleton:

```sql
create or replace function public.accept_friend_invite(
  p_invite_code text,
  p_receiver_uid uuid
)
returns void
language plpgsql
security definer
as $$
declare
  v_invite public.friend_invites%rowtype;
begin
  select *
  into v_invite
  from public.friend_invites
  where invite_code = p_invite_code
  for update;

  if not found then
    raise exception 'Invite not found';
  end if;

  if v_invite.status <> 'pending' then
    raise exception 'Invite is not pending';
  end if;

  if v_invite.expires_at <= now() then
    raise exception 'Invite is expired';
  end if;

  update public.friend_invites
  set
    receiver_uid = p_receiver_uid,
    status = 'accepted',
    updated_at = now()
  where invite_id = v_invite.invite_id;

  update public.friends
  set uid = p_receiver_uid
  where sid = v_invite.source_friend_sid
    and (uid is null or uid = '' or uid = sid);

  if not found then
    raise exception 'Target friend row not found or already linked';
  end if;
end;
$$;
```

### 3. Add a real backend path for invite preview loading

There is an important access-control detail here.

Today, the app loads invite preview by `invite_code` before the receiver is attached.
If RLS only allows `sender_uid = auth.uid()` or `receiver_uid = auth.uid()`, the invited user cannot read the invite preview before acceptance.

Recommended secure solution:
- add an RPC like `get_friend_invite_by_code(p_invite_code text)`
- make it return only one valid pending invite
- keep the rest of the table protected by strict RLS

Suggested behavior:
- input: `invite_code`
- output: one row from `friend_invites`
- only return when the invite exists, is pending, and not expired
- this RPC can run as `security definer`

Why this is recommended:
- it avoids opening read access to all pending invites
- it supports the current QR/link flow cleanly
- it is safer than a broad `select` policy on pending rows

Fast compatibility alternative:
- temporarily relax read access for pending invites
- this is easier but less safe
- use this only if you want the preview flow working immediately before adding the RPC

### 4. Add a real backend path for reject flow

Current mobile fallback rejects an invite by updating the row directly.
With strict RLS, this can also fail before `receiver_uid` is set.

Recommended secure solution:
- add `reject_friend_invite(p_invite_code text, p_receiver_uid uuid)`

Expected behavior:
- find the invite by code
- ensure it is still pending and not expired
- set `receiver_uid = p_receiver_uid`
- set `status = 'rejected'`
- set `updated_at = now()`

If you do not add this RPC yet:
- the fallback direct update may require a temporary broader update policy
- that policy is less safe than the RPC path

### 5. Keep realtime enabled on the tables that drive the visible UI

Required realtime tables:
- `friends`
- `friend_invites`
- `transactions`
- `subscriptions`
- `account_funding`

Why:
- `friends`: the share button disappears automatically when `friends.uid` becomes non-null
- `friends`: the dedicated friend list and detail page refresh live
- `friend_invites`: sent/received invitation state updates live
- `transactions`, `subscriptions`, `account_funding`: graphs and summaries refresh live

### 6. Keep `fcm_tokens` compatible with the current app policy

The app now behaves as one active token row per `user_uid`.
You already added uniqueness, which is correct.

Backend expectations now:
- if a token row exists for the user, update it
- if not, insert it
- if historical duplicate rows still exist from older data, clean them once
- push sending should resolve at most one active row per `user_uid`

Recommended cleanup query if needed once:

```sql
delete from public.fcm_tokens a
using public.fcm_tokens b
where a.user_uid = b.user_uid
  and a.token_id < b.token_id;
```

### 7. Trigger the right push events

For the current visible friend-linking flow, the most useful push event is:
- `friend_accept`

When to send it:
- after `accept_friend_invite` succeeds
- target the original sender
- include route and payload so the app can open the right place

Recommended payload shape:

```json
{
  "category": "friend_accept",
  "title": "Friend linked",
  "body": "Your shared friend profile has been linked to a Bicount account.",
  "route": "/profile",
  "source_friend_sid": "friend-sid-value"
}
```

Important note:
- in the current share model, invite creation itself does not necessarily imply a push
- the invite is usually delivered manually by QR or external link sharing
- push at accept time is the valuable backend event to prioritize

## RLS summary

### `friend_invites`

Keep these behaviors:
- sender can read sent invites
- receiver can read received invites
- sender can insert own invites
- sender or receiver can watch their own invite updates

But also handle the preview and reject gap before `receiver_uid` is set.

Best option:
- keep strict table RLS
- expose RPCs for preview and reject

### `friends`

Keep these behaviors:
- users only read their allowed friend rows under the existing app model
- backend trusted function can update `uid` during linking

### `fcm_tokens`

Keep these behaviors:
- authenticated user can select, insert, and update only their own row
- service role can read tokens for push delivery

### `notification_events`

Keep these behaviors:
- authenticated user can read only their own notification events
- insert is done by trusted backend logic

## What the backend must not do

Do not do these during link acceptance:
- do not create a new sender-side friend row instead of updating the existing one
- do not change `friends.sid`
- do not detach historical transactions from the existing friend row
- do not mark the invite accepted without also linking `friends.uid`

If one of those happens, the app can show inconsistent friend history or keep displaying the share action incorrectly.

## Minimum validation checklist

1. A user creates a local friend with `uid = null` and records transactions.
2. That friend profile is shared by QR or link.
3. The second user signs in and opens the invite.
4. The backend returns the invite preview.
5. The second user accepts.
6. `friend_invites.status` becomes `accepted`.
7. `friend_invites.receiver_uid` is filled.
8. `public.friends.uid` is updated on the row identified by `source_friend_sid`.
9. The sender device sees the linked friend in realtime without manual refresh.
10. The share button disappears on that friend detail page.
11. A `friend_accept` notification event is written.
12. The sender receives the push if FCM is configured.

## Short conclusion

Since uniqueness on `fcm_tokens.user_uid` is already done, the priority backend work is now:
1. target invites to an exact `friends.sid`
2. securely load invite previews
3. securely accept or reject invites
4. update `public.friends.uid` on the existing row
5. push the acceptance event and propagate realtime updates

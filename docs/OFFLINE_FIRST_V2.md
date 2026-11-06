# Offline-first V2

## Backend audit (2026-11-06)

The connected Bicount Supabase project (`yudjgfypbsahpukruqta`) is **not yet
compatible** with the current V2 codecs. Migration `20260409090333`
intentionally dropped `account_funding`, `subscriptions`, and
`recurring_fundings` after moving money occurrences to `transactions` and
recurring templates to `recurring_transfert`. The mobile source still reads and
writes the three removed tables. The `account_funding` migration generated new
transaction UUIDs, so an installed-device upgrade also needs an explicit
identity mapping to avoid duplicate or orphaned local rows. Do not recreate
the removed tables to mask this mismatch; adapt the mobile data layer to the
unified backend contract in `docs/recurring_transfert_backend_actions.md`.

Realtime publication is active for `users`, `friends`, `transactions`, `debts`,
and `recurring_transfert`. Their record keys are unique. Backend RLS currently
allows anonymous `INSERT` on `transactions` with `WITH CHECK (true)`, and
`fcm_tokens` has no `DELETE` policy, so client-side duplicate cleanup cannot
remove rows. These findings require backend review before release. No remote
schema or data was changed during this audit.

## Runtime contract

- `lib/core/offline/repository.dart` owns an SQLite file per authenticated UID.
- `offline_codecs.g.dart` maps the 13 existing finance and social models to their
  existing Supabase columns and legacy SQLite table names.
- `outbox/` writes a model mutation and its outgoing intent atomically. Each
  record retains only its latest unsent state. UUID model IDs remain unchanged.
- `offline_sync.dart` pushes pending writes in order, retries failures with
  backoff, subscribes to Supabase Postgres Changes, and reconciles keyset
  paginated remote snapshots. Reconciliation runs in the background at startup
  and periodically while the app remains open. Hidden company collections and
  the unused memoji model do not add periodic requests in the visible release.
- Reads, streams, finance projections, and Analysis use local data. A missing
  local collection starts hydration from Supabase, but the read returns its
  local result within 400 ms; the stream receives later remote data.

## Conflict and deletion rules

The last acknowledged server write wins when a record has no pending local
operation. A local pending operation wins over incoming realtime and snapshot
data until it is acknowledged. The next reconciliation then reads the server
version. Deletes are queued with the stable UUID and are idempotent. Remote
deletes remove cached rows through realtime when the ID is present, or through
the next full reconciliation. A snapshot verifies missing IDs individually
before removing them and archives the prior local row. Missing delete payload
IDs are reconciled with a short debounce.

Supabase must continue to expose the existing tables through RLS to the same
users as before and publish changes for the visible finance and friend tables.
The [Supabase Flutter realtime API](https://supabase.com/docs/reference/dart/subscribe)
notes that old row data for deletes requires `REPLICA IDENTITY FULL`; the periodic
snapshot is the fallback when the deleted UUID is absent from an event.

## Installed-device migration

On first launch after upgrade, the app identifies the owner from the existing
`UserModel.uid` and copies the old SQLite database into a per-user file. It adds
missing columns, unique indexes, and the outbox without dropping tables. The
previous HTTP queue is read and converted into final per-record operations;
other queued Supabase requests are kept as authenticated replay operations.
Queued requests whose old authorization token names a different user are not
imported into the current account.
Imported job IDs prevent duplicate import on later launches. Source databases
remain untouched except after the user explicitly deletes the account. If
conversion fails, remote synchronization pauses while local data remains
available; the error is logged for recovery.

## Network-only actions

Authentication, invitation acceptance and unlinking, and account deletion
still require backend validation. Invitation creation, FCM token registration,
and Bicount Pro requests queue stable IDs for later delivery when a direct
write cannot complete. FCM retries look up the existing user row before
updating or inserting, so `fcm_tokens.user_uid` need not be unique. Pending
invitation cancellation is queued as well.
Currency calculations use cached exchange snapshots;
an uncached currency cannot be converted accurately while offline.

## Validation

Run `flutter test test/core/offline`, `flutter test`, and
`flutter build apk --debug`. Test iOS and upgrade from an installed V1 build on
real devices before release, including an unsent transaction and a remote
deletion while the app is offline. The pre-existing transaction subscription
date assertion remains a separate baseline test failure.

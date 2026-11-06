# Offline-first V2

## Backend audit (2026-11-06)

The connected Bicount Supabase project (`yudjgfypbsahpukruqta`) dropped
`account_funding`, `subscriptions`, and `recurring_fundings` in migration
`20260409090333`, after moving money occurrences to `transactions` and
recurring templates to `recurring_transfert`. Active V2 codecs and feature data
sources now read and write only the unified tables. The old model codecs are
read-only migration decoders. Legacy funding is represented as a self-income
transaction and counted once. Recurring transactions read both the older
`origin_id` link and the backend `recurring_transfert_id` link.
Editing or deleting a recurring template does not rewrite or erase already
recorded money transactions.

Realtime publication is active for `users`, `friends`, `transactions`, `debts`,
and `recurring_transfert`. Their record keys are unique. Backend RLS currently
allows anonymous `INSERT` on `transactions` with `WITH CHECK (true)`, and
`fcm_tokens` has no `DELETE` policy, so client-side duplicate cleanup cannot
remove rows. These findings require backend review before release. No remote
schema or data was changed during this audit or mobile alignment.

## Runtime contract

- `lib/core/offline/repository.dart` owns an SQLite file per authenticated UID.
- `offline_codecs.g.dart` maps active finance and social models to existing
  Supabase columns and legacy SQLite table names. The retired model codecs are
  excluded from active reads, writes, realtime, and snapshot sync.
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

The three retired finance tables are copied locally into canonical transactions
and recurring templates before synchronization. Their old UUIDs remain stable
where possible; non-UUID IDs are mapped deterministically. Before sending old
queued edits, V2 compares each provisional row with the already migrated remote
rows, adopts the remote UUID when it can identify the same record, and sends
only unmatched local work. Ambiguous matches pause reconciliation instead of
guessing or duplicating money. Old source tables and queue files are retained.

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
deletion while the app is offline.

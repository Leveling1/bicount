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
- `offline_journal.dart` optionally consumes the per-user server journal when
  built with `BICOUNT_SYNC_JOURNAL=true` and the backend enables that account.
  Otherwise the existing snapshot path remains active. Journal pages apply
  changes and advance their cursor in one SQLite transaction. A fresh snapshot
  is required on first use, cursor expiry, sequence gaps, or a capture generation
  change. An hourly full snapshot remains as a fallback for missed trigger events.
- Reads, streams, finance projections, and Analysis use local data. A missing
  local collection starts hydration from Supabase, but the read returns its
  local result within 400 ms; the stream receives later remote data.
- The last remote row applied locally is stored with the row in the same SQLite
  transaction. A pending local operation freezes that baseline, allowing a
  future conflict protocol to compare against what the device actually saw.
  In the explicitly enabled local experiment, this baseline also carries the
  journal sequence and generation observed before its fresh snapshot or event.
  A pending or unobserved row is never advanced to a newer watermark. Normal
  builds do not yet use this baseline to protect server writes.
- Explicit finance creation paths mark their queued intent as a creation. Its
  original operation UUID survives subsequent local edits and is archived with
  unresolved versions. Older queues without an original UUID stay unknown;
  later edits do not guess or upgrade that provenance. This marker is
  preparation only: a secure server-side creation protocol is not yet
  implemented.

## Conflict and deletion rules

The last acknowledged server write wins when a record has no pending local
operation. A local pending operation wins over incoming realtime and snapshot
data until it is acknowledged. The next reconciliation then reads the server
version. This is not conflict detection: a queued upsert or delete can
overwrite or remove a newer change made on another device, including an old
client. The journal only detects incoming changes and does not prevent that
race. A server-side atomic version check and a safe conflict recovery policy
are still required before the new offline implementation is release-ready.
Deletes are queued with the stable UUID and are idempotent. Remote
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
All imported operations are quarantined from automatic transmission until a
safe conflict recovery path is implemented, including requests on active tables
and raw HTTP jobs. Subsequent local edits to a guarded record remain guarded.
For databases that already imported the old queue before this protection, a
one-time additive migration guards every existing pending intent because its
origin cannot be reconstructed reliably. No queued operation is deleted by
that migration.
When a guarded upsert's complete payload already matches the same remote UUID,
the operation is archived and acknowledged locally without writing to Supabase.
Different values, absent fields, deletes, and raw requests remain guarded.
Queued requests whose old authorization token names a different user are not
imported into the current account.
Imported job IDs prevent duplicate import on later launches. Source databases
remain untouched except after the user explicitly deletes the account. If
conversion fails, remote synchronization pauses while local data remains
available; the error is logged for recovery.

The three retired finance tables are copied locally into canonical transactions
and recurring templates before synchronization. Their old UUIDs remain stable
where possible; non-UUID IDs are mapped deterministically. Before sending old
queued edits, V2 automatically resolves a provisional row only when the remote
UUID is identical and no operation for it is pending. Matching UUIDs do not
prove which edit is newer, so pending operations remain quarantined. The
historical backend migration generated new UUIDs for
some rows and did not preserve a mapping. Those records and pending operations
remain local and are excluded from outgoing sync until a trustworthy recovery
method is implemented. Other records may synchronize. Source tables and queue
files are retained. Unresolved rows can temporarily appear alongside their
server counterparts, so an installed-device upgrade is not release-ready.

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

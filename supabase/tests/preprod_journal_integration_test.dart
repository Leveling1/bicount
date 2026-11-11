import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_conditional_delivery.dart';
import 'package:bicount/core/offline/offline_journal.dart';
import 'package:bicount/core/offline/offline_merge.dart';
import 'package:bicount/core/offline/offline_remote_snapshot.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

void main() {
  sqfliteFfiInit();
  final anon = Platform.environment['BICOUNT_PREPROD_TEST_ANON'];
  final token = Platform.environment['BICOUNT_PREPROD_TEST_TOKEN'];
  final refresh = Platform.environment['BICOUNT_PREPROD_TEST_REFRESH'];
  final uid = Platform.environment['BICOUNT_PREPROD_TEST_UID'];
  final secondUid = Platform.environment['BICOUNT_PREPROD_TEST_SECOND_UID'];
  final secondToken = Platform.environment['BICOUNT_PREPROD_TEST_SECOND_TOKEN'];

  Future<Database> createDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    for (final codec in [
      userModelCodec,
      friendsModelCodec,
      transactionModelCodec,
      debtModelCodec,
      recurringTransfertModelCodec,
    ]) {
      final columns = codec.localColumns.values
          .toSet()
          .map((name) => '"$name"')
          .join(', ');
      await db.execute(
        'CREATE TABLE "${codec.localTable}" '
        '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $columns)',
      );
    }
    await db.execute(
      'CREATE TABLE bicount_removed_record_archive '
      '(table_name TEXT, record_id TEXT, payload TEXT, removed_at TEXT, '
      'PRIMARY KEY(table_name, record_id))',
    );
    await OfflineOutbox(db).initialize();
    return db;
  }

  test(
    'local journal applies remote creates and deletes to SQLite',
    () async {
      final testUid = uid!;
      final testToken = token!;
      final db = await createDatabase();
      addTearDown(db.close);
      final client = SupabaseClient('http://127.0.0.1:54321', anon!);
      addTearDown(client.dispose);
      await client.auth.setSession(refresh!, accessToken: testToken);
      const merge = OfflineMerge();
      final journal = OfflineJournal(
        client: client,
        db: db,
        userId: testUid,
        currentUserId: () => testUid,
        notify: (_) {},
        snapshot: (codec, sequence, generation) async {
          final remote = await client.from(codec.table).select();
          await merge.snapshot(
            db: db,
            codec: codec,
            userId: testUid,
            rows: remote,
            confirmedDeletes: const [],
            observedSequence: sequence,
            observedGeneration: generation,
          );
        },
      );
      expect(await journal.synchronize(), isTrue);
      final otherUid = secondUid!;
      final otherDb = await createDatabase();
      addTearDown(otherDb.close);
      final otherClient = SupabaseClient(
        'http://127.0.0.1:54321',
        anon,
        accessToken: () async => secondToken,
      );
      addTearDown(otherClient.dispose);
      final otherJournal = OfflineJournal(
        client: otherClient,
        db: otherDb,
        userId: otherUid,
        currentUserId: () => otherUid,
        notify: (_) {},
        snapshot: (codec, sequence, generation) async {
          final remote = await otherClient.from(codec.table).select();
          await merge.snapshot(
            db: otherDb,
            codec: codec,
            userId: otherUid,
            rows: remote,
            confirmedDeletes: const [],
            observedSequence: sequence,
            observedGeneration: generation,
          );
        },
      );
      expect(await otherJournal.synchronize(), isTrue);

      final friendId = const Uuid().v4();
      final transactionId = const Uuid().v4();
      await client.realtime.setAuth(testToken);
      final subscribed = Completer<void>();
      final receivedInsert = Completer<void>();
      final channel = client.channel('preprod-${const Uuid().v4()}');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'transactions',
        callback: (payload) {
          if (payload.newRecord['tid'] == transactionId &&
              !receivedInsert.isCompleted) {
            receivedInsert.complete();
          }
        },
      );
      channel.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed &&
            !subscribed.isCompleted) {
          subscribed.complete();
        } else if (status == RealtimeSubscribeStatus.channelError &&
            !subscribed.isCompleted) {
          subscribed.completeError(
            StateError('Realtime subscription error: $error'),
          );
        }
      });
      await subscribed.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw StateError('Realtime subscription timed out'),
      );
      await client.from('friends').insert({
        'sid': friendId,
        'fid': testUid,
        'uid': otherUid,
        'username': 'Preprod contact',
        'relation_type': 0,
      });
      await client.from('transactions').insert({
        'tid': transactionId,
        'gtid': const Uuid().v4(),
        'uid': testUid,
        'name': 'Preprod payment',
        'type': 0,
        'sender_id': testUid,
        'beneficiary_id': friendId,
        'date': '2026-01-01T00:00:00Z',
        'amount': 42,
        'currency': 'CDF',
      });
      await receivedInsert.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw StateError('Realtime insert event timed out'),
      );
      await client.removeChannel(channel);
      expect(await journal.synchronize(), isTrue);
      expect(await otherJournal.synchronize(), isTrue);
      expect(
        await db.query(
          transactionModelCodec.localTable,
          where: 'tid = ?',
          whereArgs: [transactionId],
        ),
        hasLength(1),
      );
      expect(
        await otherDb.query(
          transactionModelCodec.localTable,
          where: 'tid = ?',
          whereArgs: [transactionId],
        ),
        hasLength(1),
      );

      final outbox = OfflineOutbox(db);
      final stale = OfflineOperation(
        userId: testUid,
        collection: 'transactions',
        recordId: transactionId,
        action: 'upsert',
        payload: {'tid': transactionId, 'amount': 43},
      );
      await outbox.commit(
        stale,
        (tx) => tx.update(
          transactionModelCodec.localTable,
          {'amount': 43},
          where: 'tid = ?',
          whereArgs: [transactionId],
        ),
      );
      await client
          .from('transactions')
          .update({'amount': 44})
          .eq('tid', transactionId);
      await client
          .from('transactions')
          .update({'amount': 42})
          .eq('tid', transactionId);
      await deliverConditionalOperation(
        db: db,
        client: client,
        operation: stale,
        currentUserId: () => testUid,
      );
      final archivedConflicts = await db.query('bicount_sync_conflict_archive');
      expect(archivedConflicts, hasLength(1));
      expect(
        (jsonDecode(archivedConflicts.single['remote_payload'] as String)
            as Map)['amount'],
        42,
      );
      expect(
        (await db.query('bicount_sync_outbox')).single['operation_id'],
        stale.id,
      );
      final newerServerRow = await client
          .from('transactions')
          .select()
          .eq('tid', transactionId)
          .single();
      expect((newerServerRow['amount'] as num).toDouble(), 42);

      // Test-only resolution of the synthetic conflict, then exercise the
      // actual successful client/server path with the refreshed baseline.
      await outbox.acknowledge(testUid, stale.id);
      expect(await journal.synchronize(), isTrue);
      final valid = OfflineOperation(
        userId: testUid,
        collection: 'transactions',
        recordId: transactionId,
        action: 'upsert',
        payload: {'tid': transactionId, 'amount': 45},
      );
      await outbox.commit(
        valid,
        (tx) => tx.update(
          transactionModelCodec.localTable,
          {'amount': 45},
          where: 'tid = ?',
          whereArgs: [transactionId],
        ),
      );
      await deliverConditionalOperation(
        db: db,
        client: client,
        operation: valid,
        currentUserId: () => testUid,
      );
      expect(await outbox.pending(testUid), isEmpty);
      expect(
        (await client
            .from('transactions')
            .select('amount')
            .eq('tid', transactionId)
            .single())['amount'],
        45,
      );

      await client.from('transactions').delete().eq('tid', transactionId);
      expect(await journal.synchronize(), isTrue);
      expect(await otherJournal.synchronize(), isTrue);
      expect(
        await db.query(
          transactionModelCodec.localTable,
          where: 'tid = ?',
          whereArgs: [transactionId],
        ),
        isEmpty,
      );
      expect(
        await otherDb.query(
          transactionModelCodec.localTable,
          where: 'tid = ?',
          whereArgs: [transactionId],
        ),
        isEmpty,
      );
      final pagedIds = List.generate(101, (_) => const Uuid().v4());
      await client.from('transactions').insert([
        for (final id in pagedIds)
          {
            'tid': id,
            'gtid': const Uuid().v4(),
            'uid': testUid,
            'name': 'Journal pagination',
            'type': 0,
            'sender_id': testUid,
            'beneficiary_id': friendId,
            'date': '2026-01-01T00:00:00Z',
            'amount': 1,
            'currency': 'CDF',
          },
      ]);
      expect(await journal.synchronize(), isTrue);
      final localIds = (await db.query(
        transactionModelCodec.localTable,
      )).map((row) => row['tid']).toSet();
      expect(localIds, containsAll(pagedIds));
    },
    skip:
        anon == null ||
            token == null ||
            uid == null ||
            refresh == null ||
            secondUid == null ||
            secondToken == null
        ? 'Requires the isolated local preproduction test account.'
        : false,
  );

  test(
    'local snapshot retrieves more than one page without missing rows',
    () async {
      final testUid = uid!;
      final client = SupabaseClient(
        'http://127.0.0.1:54321',
        anon!,
        accessToken: () async => token,
      );
      addTearDown(client.dispose);
      final friendId = const Uuid().v4();
      await client.from('friends').insert({
        'sid': friendId,
        'fid': testUid,
        'username': 'Preprod pagination',
        'relation_type': 0,
      });
      final ids = List.generate(501, (_) => const Uuid().v4());
      await client.from('transactions').insert([
        for (final id in ids)
          {
            'tid': id,
            'gtid': const Uuid().v4(),
            'uid': testUid,
            'name': 'Pagination test',
            'type': 0,
            'sender_id': testUid,
            'beneficiary_id': friendId,
            'date': '2026-01-01T00:00:00Z',
            'amount': 1,
            'currency': 'CDF',
          },
      ]);
      final rows = await fetchOfflineRemoteSnapshot(
        client: client,
        codec: transactionModelCodec,
        isCurrentUser: () => true,
      );
      expect(rows.map((row) => row['tid']).toSet(), containsAll(ids));
    },
    skip: anon == null || token == null || uid == null
        ? 'Requires the isolated local preproduction test account.'
        : false,
  );
}

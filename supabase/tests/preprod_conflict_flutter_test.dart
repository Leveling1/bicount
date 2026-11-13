import 'dart:convert';
import 'dart:io';

import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_conditional_delivery.dart';
import 'package:bicount/core/offline/offline_conflict_clock.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

void main() {
  sqfliteFfiInit();
  final key = Platform.environment['BICOUNT_PREPROD_TEST_ANON'];
  final token = Platform.environment['BICOUNT_PREPROD_TEST_TOKEN'];
  final uid = Platform.environment['BICOUNT_PREPROD_TEST_UID'];
  final remoteTid = Platform.environment['BICOUNT_PREPROD_TEST_REMOTE_WIN_TID'];
  final localTid = Platform.environment['BICOUNT_PREPROD_TEST_LOCAL_WIN_TID'];
  final deletedTid = Platform.environment['BICOUNT_PREPROD_TEST_DELETED_TID'];
  final localDeleteTid =
      Platform.environment['BICOUNT_PREPROD_TEST_LOCAL_DELETE_TID'];

  Future<void> runCase({
    required String tid,
    required bool remoteWins,
    bool remoteDelete = false,
    bool localDelete = false,
  }) async {
    if (key == null || token == null || uid == null)
      throw StateError('Missing local test credentials');
    final client = SupabaseClient(
      'http://127.0.0.1:54321',
      key,
      accessToken: () async => token,
    );
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(client.dispose);
    addTearDown(db.close);
    final outbox = OfflineOutbox(db);
    await outbox.initialize();
    final codec = transactionModelCodec;
    final columns = codec.localColumns.values
        .toSet()
        .map((column) => '"$column"')
        .join(', ');
    await db.execute(
      'CREATE TABLE "${codec.localTable}" (_local_id INTEGER PRIMARY KEY, $columns)',
    );
    await db.execute(
      'CREATE TABLE bicount_removed_record_archive (table_name TEXT, record_id TEXT, payload TEXT, removed_at TEXT, PRIMARY KEY (table_name, record_id))',
    );
    await client.from('transactions').insert({
      'tid': tid,
      'uid': uid,
      'gtid': const Uuid().v4(),
      'name': 'Conflict test',
      'type': 0,
      'sender_id': uid,
      'beneficiary_id': uid,
      'date': '2026-01-01T00:00:00Z',
      'amount': 10,
      'currency': 'CDF',
    });
    final baseline = await client
        .from('transactions')
        .select()
        .eq('tid', tid)
        .single();
    final marker = await client.rpc('bicount_sync_status') as Map;
    await db.insert('bicount_remote_baseline', {
      'user_id': uid,
      'collection': 'transactions',
      'record_id': tid,
      'remote_payload': jsonEncode(baseline),
      'journal_sequence': marker['latest_sequence'],
      'journal_generation': marker['generation'],
    });
    final clock = OfflineConflictClock();
    final started = clock.beginSample();
    final serverTime = DateTime.parse(
      await client.rpc('bicount_server_clock') as String,
    );
    clock.completeSample(started, serverTime);
    var edit = clock.estimate();
    if (remoteWins) await Future<void>.delayed(const Duration(seconds: 6));
    if (remoteDelete) {
      await client.from('transactions').delete().eq('tid', tid);
    } else {
      await client.from('transactions').update({'amount': 20}).eq('tid', tid);
    }
    if (!remoteWins) {
      await Future<void>.delayed(const Duration(seconds: 6));
      edit = clock.estimate();
    }
    if (edit == null) throw StateError('Clock sample unavailable');
    await outbox.commit(
      OfflineOperation(
        userId: uid,
        collection: 'transactions',
        recordId: tid,
        action: localDelete ? 'delete' : 'upsert',
        payload: {'tid': tid, 'amount': 15},
        editedEarliest: edit.earliest,
        editedLatest: edit.latest,
      ),
      (tx) async {
        if (!localDelete) {
          await tx.insert(
            codec.localTable,
            codec.encodeLocal(codec.decodeRemote({...baseline, 'amount': 15})),
          );
        }
      },
    );
    final op = (await outbox.pending(uid)).single;
    await deliverConditionalOperation(
      db: db,
      client: client,
      operation: op,
      currentUserId: () => uid,
      notify: (_) {},
    );
    expect(await outbox.pending(uid), isEmpty);
    final server = await client
        .from('transactions')
        .select('amount')
        .eq('tid', tid);
    if (remoteDelete || localDelete) {
      expect(server, isEmpty);
    } else {
      expect(server.single['amount'], remoteWins ? 20 : 15);
    }
    expect(await db.query('bicount_sync_conflict_archive'), hasLength(1));
    if (remoteDelete || localDelete) {
      expect(await db.query(codec.localTable), isEmpty);
    } else if (remoteWins)
      expect((await db.query(codec.localTable)).single['amount'], 20);
  }

  test('newer remote change wins over earlier offline edit', () async {
    if (remoteTid == null) throw StateError('Missing local test id');
    await runCase(tid: remoteTid, remoteWins: true);
  });
  test('newer offline edit wins with a conditional update', () async {
    if (localTid == null) throw StateError('Missing local test id');
    await runCase(tid: localTid, remoteWins: false);
  });
  test('newer remote deletion wins and archives the offline edit', () async {
    if (deletedTid == null) throw StateError('Missing local test id');
    await runCase(tid: deletedTid, remoteWins: true, remoteDelete: true);
  });
  test('newer offline deletion wins over a remote edit', () async {
    if (localDeleteTid == null) throw StateError('Missing local test id');
    await runCase(tid: localDeleteTid, remoteWins: false, localDelete: true);
  });
}

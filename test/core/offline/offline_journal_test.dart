import 'dart:convert';

import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_journal.dart';
import 'package:bicount/core/offline/offline_merge.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  sqfliteFfiInit();

  Future<Database> database() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final columns = transactionModelCodec.localColumns.values
        .toSet()
        .map((column) => '"$column"')
        .join(', ');
    await db.execute(
      'CREATE TABLE TransactionModel (_local_id INTEGER PRIMARY KEY, $columns)',
    );
    await db.execute(
      'CREATE TABLE bicount_removed_record_archive '
      '(table_name TEXT, record_id TEXT, payload TEXT, removed_at TEXT, '
      'PRIMARY KEY(table_name, record_id))',
    );
    await OfflineOutbox(db).initialize();
    return db;
  }

  Map<String, dynamic> transaction(String id, Object amount) => {
    'tid': id,
    'gtid': 'group-$id',
    'uid': 'user-1',
    'name': 'Payment',
    'type': 0,
    'sender_id': 'user-1',
    'beneficiary_id': 'friend-1',
    'date': '2026-01-01',
    'note': '',
    'amount': amount,
    'currency': 'CDF',
  };

  http.Response jsonResponse(Object body, http.BaseRequest request) =>
      http.Response(
        jsonEncode(body),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );

  test('disabled server keeps the snapshot synchronization path', () async {
    final db = await database();
    addTearDown(db.close);
    final client = SupabaseClient(
      'http://localhost',
      'local-test-key',
      httpClient: MockClient((request) async {
        expect(request.url.path, endsWith('/rpc/bicount_sync_status'));
        return jsonResponse({'enabled': false}, request);
      }),
    );
    addTearDown(client.dispose);
    var snapshots = 0;
    final journal = OfflineJournal(
      client: client,
      db: db,
      userId: 'user-1',
      currentUserId: () => 'user-1',
      snapshot: (_, _, _) async => snapshots++,
      notify: (_) {},
    );
    expect(await journal.synchronize(), isFalse);
    expect(snapshots, 0);
  });

  test('bootstrap never advances a pending operation baseline', () async {
    final db = await database();
    addTearDown(db.close);
    for (final id in ['pending', 'clean', 'stale-unseen']) {
      await db.insert('bicount_remote_baseline', {
        'user_id': 'user-1',
        'collection': 'transactions',
        'record_id': id,
        'remote_payload': jsonEncode({'tid': id}),
        'journal_sequence': 2,
        'journal_generation': 1,
      });
    }
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: 'user-1',
        collection: 'transactions',
        recordId: 'pending',
        action: 'upsert',
        payload: {'tid': 'pending'},
      ),
      (_) async {},
    );
    final client = SupabaseClient(
      'http://localhost',
      'local-test-key',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse({
            'enabled': true,
            'generation': 2,
            'latest_sequence': 5,
            'oldest_available_sequence': 1,
          }, request);
        }
        if (request.url.path.endsWith('/bicount_sync_events')) {
          return jsonResponse([], request);
        }
        throw StateError('Unexpected request');
      }),
    );
    addTearDown(client.dispose);
    final journal = OfflineJournal(
      client: client,
      db: db,
      userId: 'user-1',
      currentUserId: () => 'user-1',
      snapshot: (codec, sequence, generation) async {
        if (codec.table != 'transactions') return;
        await const OfflineMerge().snapshot(
          db: db,
          codec: codec,
          userId: 'user-1',
          rows: [transaction('pending', 10), transaction('clean', 10)],
          confirmedDeletes: const [],
          observedSequence: sequence,
          observedGeneration: generation,
        );
      },
      notify: (_) {},
    );
    expect(await journal.synchronize(), isTrue);
    final rows = await db.query(
      'bicount_remote_baseline',
      orderBy: 'record_id',
    );
    expect(rows.first['journal_sequence'], 5);
    expect(rows.first['journal_generation'], 2);
    expect(rows[1]['journal_sequence'], 2);
    expect(rows[1]['journal_generation'], 1);
    expect(rows.last['record_id'], 'stale-unseen');
    expect(rows.last['journal_sequence'], 2);
    expect(rows.last['journal_generation'], 1);
  });

  test('bootstrap, invalidation and journal page advance the cursor', () async {
    final db = await database();
    addTearDown(db.close);
    final snapshots = <String>[];
    final notifications = <Type>[];
    final client = SupabaseClient(
      'http://localhost',
      'local-test-key',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse({
            'enabled': true,
            'generation': 1,
            'latest_sequence': 0,
            'oldest_available_sequence': 1,
          }, request);
        }
        if (request.url.path.endsWith('/bicount_sync_events')) {
          expect(
            request.url.queryParameters['order'],
            startsWith('sequence.asc'),
          );
          return jsonResponse([
            {
              'sequence': 1,
              'table_name': 'transactions',
              'record_id': 'new-id',
              'change_kind': 'upsert',
            },
            {
              'sequence': 2,
              'table_name': 'transactions',
              'record_id': 'old-id',
              'change_kind': 'delete',
            },
            {
              'sequence': 3,
              'table_name': 'friends',
              'record_id': null,
              'change_kind': 'invalidate',
            },
          ], request);
        }
        if (request.url.path.endsWith('/transactions')) {
          return jsonResponse([transaction('new-id', 42)], request);
        }
        throw StateError('Unexpected local mock request: ${request.url.path}');
      }),
    );
    addTearDown(client.dispose);
    final journal = OfflineJournal(
      client: client,
      db: db,
      userId: 'user-1',
      currentUserId: () => 'user-1',
      snapshot: (codec, _, _) async {
        snapshots.add(codec.table);
        if (codec.table == 'transactions') {
          await db.insert('TransactionModel', {'tid': 'old-id', 'name': 'Old'});
        }
      },
      notify: notifications.add,
    );

    expect(await journal.synchronize(), isTrue);
    expect(snapshots, hasLength(6));
    expect(snapshots.where((table) => table == 'friends'), hasLength(2));
    expect((await db.query('bicount_journal_cursor')).single['sequence'], 3);
    final rows = await db.query('TransactionModel');
    expect(rows.map((row) => row['tid']), ['new-id']);
    expect(rows.single['amount'], 42);
    final baseline = await db.query(
      'bicount_remote_baseline',
      where: 'collection = ? AND record_id = ?',
      whereArgs: ['transactions', 'new-id'],
    );
    expect(baseline.single['journal_sequence'], 3);
    expect(baseline.single['journal_generation'], 1);
    expect(await db.query('bicount_removed_record_archive'), hasLength(1));
    expect(notifications, contains(transactionModelCodec.modelType));
  });

  test('a failed journal page rolls back its rows and cursor', () async {
    final db = await database();
    addTearDown(db.close);
    final client = SupabaseClient(
      'http://localhost',
      'local-test-key',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse({
            'enabled': true,
            'generation': 1,
            'latest_sequence': 0,
            'oldest_available_sequence': 1,
          }, request);
        }
        if (request.url.path.endsWith('/bicount_sync_events')) {
          return jsonResponse([
            for (var i = 1; i <= 2; i++)
              {
                'sequence': i,
                'table_name': 'transactions',
                'record_id': 'row-$i',
                'change_kind': 'upsert',
              },
          ], request);
        }
        if (request.url.path.endsWith('/transactions')) {
          return jsonResponse([
            transaction('row-1', 42),
            transaction('row-2', 'not-a-number'),
          ], request);
        }
        throw StateError('Unexpected local mock request');
      }),
    );
    addTearDown(client.dispose);
    final journal = OfflineJournal(
      client: client,
      db: db,
      userId: 'user-1',
      currentUserId: () => 'user-1',
      snapshot: (_, _, _) async {},
      notify: (_) {},
    );

    await expectLater(journal.synchronize(), throwsA(isA<TypeError>()));
    expect(await db.query('TransactionModel'), isEmpty);
    expect((await db.query('bicount_journal_cursor')).single['sequence'], 0);
  });

  test('capture configuration change forces a fresh snapshot', () async {
    final db = await database();
    addTearDown(db.close);
    await db.execute(
      'CREATE TABLE bicount_journal_cursor '
      '(user_id TEXT PRIMARY KEY, sequence INTEGER NOT NULL, '
      'generation INTEGER NOT NULL)',
    );
    await db.insert('bicount_journal_cursor', {
      'user_id': 'user-1',
      'sequence': 0,
      'generation': 1,
    });
    final client = SupabaseClient(
      'http://localhost',
      'local-test-key',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
          return jsonResponse({
            'enabled': true,
            'generation': 2,
            'latest_sequence': 0,
            'oldest_available_sequence': 1,
          }, request);
        }
        return jsonResponse([], request);
      }),
    );
    addTearDown(client.dispose);
    final snapshots = <String>[];
    final journal = OfflineJournal(
      client: client,
      db: db,
      userId: 'user-1',
      currentUserId: () => 'user-1',
      snapshot: (codec, _, _) async => snapshots.add(codec.table),
      notify: (_) {},
    );

    expect(await journal.synchronize(), isTrue);
    expect(snapshots, hasLength(5));
    expect((await db.query('bicount_journal_cursor')).single['generation'], 2);
  });

  test(
    'a journal gap discards the cursor and requests a new snapshot',
    () async {
      final db = await database();
      addTearDown(db.close);
      await db.execute(
        'CREATE TABLE bicount_journal_cursor '
        '(user_id TEXT PRIMARY KEY, sequence INTEGER NOT NULL, '
        'generation INTEGER NOT NULL)',
      );
      await db.insert('bicount_journal_cursor', {
        'user_id': 'user-1',
        'sequence': 0,
        'generation': 1,
      });
      var pageRequests = 0;
      final client = SupabaseClient(
        'http://localhost',
        'local-test-key',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/rpc/bicount_sync_status')) {
            return jsonResponse({
              'enabled': true,
              'generation': 1,
              'latest_sequence': 2,
              'oldest_available_sequence': 1,
            }, request);
          }
          pageRequests++;
          return jsonResponse(
            pageRequests == 1
                ? [
                    {
                      'sequence': 2,
                      'table_name': 'transactions',
                      'record_id': 'row-2',
                      'change_kind': 'delete',
                    },
                  ]
                : [],
            request,
          );
        }),
      );
      addTearDown(client.dispose);
      final snapshots = <String>[];
      final journal = OfflineJournal(
        client: client,
        db: db,
        userId: 'user-1',
        currentUserId: () => 'user-1',
        snapshot: (codec, _, _) async => snapshots.add(codec.table),
        notify: (_) {},
      );

      await expectLater(journal.synchronize(), throwsStateError);
      expect(await db.query('bicount_journal_cursor'), isEmpty);
      expect(await journal.synchronize(), isTrue);
      expect(snapshots, hasLength(5));
      expect((await db.query('bicount_journal_cursor')).single['sequence'], 2);
    },
  );
}

import 'dart:convert';

import 'package:bicount/core/offline/offline_codecs.g.dart';
import 'package:bicount/core/offline/offline_timed_conflict.dart';
import 'package:bicount/core/offline/offline_identical_remote.dart';
import 'package:bicount/core/offline/outbox/offline_operation.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late OfflineOutbox outbox;
  final remote = <String, dynamic>{
    'tid': 'id',
    'uid': 'u',
    'gtid': 'g',
    'name': 'server',
    'type': 0,
    'sender_id': 'u',
    'beneficiary_id': 'u',
    'date': '2026-11-01T00:00:00Z',
    'amount': 20,
    'currency': 'CDF',
  };
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    outbox = OfflineOutbox(db);
    await outbox.initialize();
    final codec = transactionModelCodec;
    final columns = codec.localColumns.values
        .toSet()
        .map((name) => '"$name"')
        .join(', ');
    await db.execute(
      'CREATE TABLE "${codec.localTable}" (_local_id INTEGER PRIMARY KEY, $columns)',
    );
    await db.execute(
      'CREATE TABLE bicount_removed_record_archive (table_name TEXT, record_id TEXT, payload TEXT, removed_at TEXT, PRIMARY KEY (table_name, record_id))',
    );
    await db.insert('bicount_remote_baseline', {
      'user_id': 'u',
      'collection': 'transactions',
      'record_id': 'id',
      'remote_payload': jsonEncode({...remote, 'amount': 10}),
      'journal_sequence': 1,
      'journal_generation': 1,
    });
  });
  tearDown(() => db.close());

  Future<OfflineOperation> queue(DateTime? earliest, DateTime? latest) async {
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'id',
        action: 'upsert',
        payload: {...remote, 'amount': 15},
        editedEarliest: earliest,
        editedLatest: latest,
      ),
      (tx) async {
        await tx.insert(
          transactionModelCodec.localTable,
          transactionModelCodec.encodeLocal(
            transactionModelCodec.decodeRemote({...remote, 'amount': 15}),
          ),
        );
      },
    );
    return (await outbox.pending('u')).single;
  }

  http.Response response(http.Request request, Object value) => http.Response(
    jsonEncode(value),
    200,
    request: request,
    headers: {'content-type': 'application/json'},
  );

  test(
    'newer server change is applied and local value remains archived',
    () async {
      final op = await queue(
        DateTime.utc(2026, 11, 7),
        DateTime.utc(2026, 11, 7, 0, 0, 5),
      );
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient(
          (request) async => response(request, {
            'status': 'observed',
            'row': remote,
            'remote_time': '2026-11-08T00:00:00Z',
            'server_time': '2026-11-10T00:00:00Z',
            'journal_sequence': 2,
            'journal_generation': 1,
          }),
        ),
      );
      addTearDown(client.dispose);
      expect(
        await resolveTimedConflict(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isTrue,
      );
      expect(
        (await db.query(transactionModelCodec.localTable)).single['amount'],
        20,
      );
      expect(await outbox.pending('u'), isEmpty);
      expect(await db.query('bicount_sync_conflict_archive'), hasLength(1));
    },
  );

  test(
    'newer local change uses conditional update and archives server value',
    () async {
      final op = await queue(
        DateTime.utc(2026, 11, 9),
        DateTime.utc(2026, 11, 9, 0, 0, 5),
      );
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('bicount_observe_conflict')) {
            return response(request, {
              'status': 'observed',
              'row': remote,
              'remote_time': '2026-11-08T00:00:00Z',
              'server_time': '2026-11-10T00:00:00Z',
              'journal_sequence': 2,
              'journal_generation': 1,
            });
          }
          return response(request, {
            'status': 'applied',
            'row': {...remote, 'amount': 15},
            'journal_sequence': 3,
            'journal_generation': 1,
          });
        }),
      );
      addTearDown(client.dispose);
      expect(
        await resolveTimedConflict(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isTrue,
      );
      expect(await outbox.pending('u'), isEmpty);
      final archive = (await db.query('bicount_sync_conflict_archive')).single;
      expect(
        (jsonDecode(archive['remote_payload'] as String) as Map)['amount'],
        20,
      );
    },
  );

  test('missing or overlapping time cannot pick a winner', () async {
    final op = await queue(null, null);
    final client = SupabaseClient(
      'http://localhost:54321',
      'test',
      httpClient: MockClient(
        (_) async => throw StateError('Unexpected network'),
      ),
    );
    addTearDown(client.dispose);
    expect(
      await resolveTimedConflict(
        db: db,
        client: client,
        operation: op,
        currentUserId: () => 'u',
        notify: (_) {},
      ),
      isFalse,
    );
    expect((await outbox.pending('u')).single.id, op.id);
  });

  test('overlapping time windows leave the operation untouched', () async {
    final op = await queue(
      DateTime.utc(2026, 11, 8),
      DateTime.utc(2026, 11, 8, 0, 0, 5),
    );
    final client = SupabaseClient(
      'http://localhost:54321',
      'test',
      httpClient: MockClient(
        (request) async => response(request, {
          'status': 'observed',
          'row': remote,
          'remote_time': '2026-11-08T00:00:03Z',
          'server_time': '2026-11-10T00:00:00Z',
          'journal_sequence': 2,
          'journal_generation': 1,
        }),
      ),
    );
    addTearDown(client.dispose);
    expect(
      await resolveTimedConflict(
        db: db,
        client: client,
        operation: op,
        currentUserId: () => 'u',
        notify: (_) {},
      ),
      isFalse,
    );
    expect((await outbox.pending('u')).single.id, op.id);
    expect(await db.query('bicount_sync_conflict_archive'), isEmpty);
  });

  test(
    'a server edit racing the resolution preserves both versions and retries',
    () async {
      final op = await queue(
        DateTime.utc(2026, 11, 9),
        DateTime.utc(2026, 11, 9, 0, 0, 5),
      );
      var calls = 0;
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient((request) async {
          calls++;
          if (request.url.path.endsWith('bicount_observe_conflict')) {
            return response(request, {
              'status': 'observed',
              'row': remote,
              'remote_time': '2026-11-08T00:00:00Z',
              'server_time': '2026-11-10T00:00:00Z',
              'journal_sequence': 2,
              'journal_generation': 1,
            });
          }
          return response(request, {
            'status': 'conflict',
            'row': {...remote, 'amount': 25},
          });
        }),
      );
      addTearDown(client.dispose);
      expect(
        await resolveTimedConflict(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isFalse,
      );
      expect(calls, 2);
      expect((await outbox.pending('u')).single.id, op.id);
      expect(
        (await db.query('bicount_sync_conflict_archive')).single['reason'],
        'local_winner',
      );
    },
  );
  test(
    'later server deletion removes the cached row but archives the offline edit',
    () async {
      final op = await queue(
        DateTime.utc(2026, 11, 7),
        DateTime.utc(2026, 11, 7, 0, 0, 5),
      );
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('bicount_observe_conflict')) {
            return response(request, {'status': 'unavailable'});
          }
          return response(request, {
            'status': 'deleted',
            'remote_time': '2026-11-08T00:00:00Z',
            'server_time': '2026-11-10T00:00:00Z',
            'journal_sequence': 2,
            'journal_generation': 1,
          });
        }),
      );
      addTearDown(client.dispose);
      expect(
        await resolveTimedConflict(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isTrue,
      );
      expect(await db.query(transactionModelCodec.localTable), isEmpty);
      expect(await outbox.pending('u'), isEmpty);
      expect(await db.query('bicount_sync_conflict_archive'), hasLength(1));
    },
  );

  test(
    'later local edit after deletion remains queued until resurrection is safe',
    () async {
      final op = await queue(
        DateTime.utc(2026, 11, 9),
        DateTime.utc(2026, 11, 9, 0, 0, 5),
      );
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('bicount_observe_conflict'))
            return response(request, {'status': 'unavailable'});
          return response(request, {
            'status': 'deleted',
            'remote_time': '2026-11-08T00:00:00Z',
            'server_time': '2026-11-10T00:00:00Z',
            'journal_sequence': 2,
            'journal_generation': 1,
          });
        }),
      );
      addTearDown(client.dispose);
      expect(
        await resolveTimedConflict(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isFalse,
      );
      expect((await outbox.pending('u')).single.id, op.id);
    },
  );
  test(
    'baseline-less intent can retire only when remote fields already match',
    () async {
      final op = await queue(null, null);
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('bicount_sync_status')) {
            return response(request, {
              'enabled': true,
              'latest_sequence': 3,
              'generation': 1,
            });
          }
          return response(request, {...remote, 'amount': 15});
        }),
      );
      addTearDown(client.dispose);
      expect(
        await acknowledgeIdenticalRemote(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isTrue,
      );
      expect(await outbox.pending('u'), isEmpty);
      expect(
        (await db.query('bicount_remote_baseline')).single['journal_sequence'],
        3,
      );
    },
  );

  test(
    'baseline-less intent is retained when any remote field differs',
    () async {
      final op = await queue(null, null);
      final client = SupabaseClient(
        'http://localhost:54321',
        'test',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('bicount_sync_status')) {
            return response(request, {
              'enabled': true,
              'latest_sequence': 3,
              'generation': 1,
            });
          }
          return response(request, remote);
        }),
      );
      addTearDown(client.dispose);
      expect(
        await acknowledgeIdenticalRemote(
          db: db,
          client: client,
          operation: op,
          currentUserId: () => 'u',
          notify: (_) {},
        ),
        isFalse,
      );
      expect((await outbox.pending('u')).single.id, op.id);
    },
  );
  test('matching local and remote deletions need no resurrection', () async {
    await queue(DateTime.utc(2026, 11, 9), DateTime.utc(2026, 11, 9, 0, 0, 5));
    await outbox.commit(
      OfflineOperation(
        userId: 'u',
        collection: 'transactions',
        recordId: 'id',
        action: 'delete',
        payload: {'tid': 'id'},
        editedEarliest: DateTime.utc(2026, 11, 9),
        editedLatest: DateTime.utc(2026, 11, 9, 0, 0, 5),
      ),
      (tx) async {
        await tx.delete(transactionModelCodec.localTable);
      },
    );
    final op = (await outbox.pending('u')).single;
    final client = SupabaseClient(
      'http://localhost:54321',
      'test',
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('bicount_observe_conflict'))
          return response(request, {'status': 'unavailable'});
        return response(request, {
          'status': 'deleted',
          'remote_time': '2026-11-08T00:00:00Z',
          'server_time': '2026-11-10T00:00:00Z',
          'journal_sequence': 2,
          'journal_generation': 1,
        });
      }),
    );
    addTearDown(client.dispose);
    expect(
      await resolveTimedConflict(
        db: db,
        client: client,
        operation: op,
        currentUserId: () => 'u',
        notify: (_) {},
      ),
      isTrue,
    );
    expect(await outbox.pending('u'), isEmpty);
  });
}

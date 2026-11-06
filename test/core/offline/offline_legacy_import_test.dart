import 'dart:convert';
import 'dart:io';

import 'package:bicount/core/offline/offline_legacy_import.dart';
import 'package:bicount/core/offline/legacy_uuid.dart';
import 'package:bicount/core/offline/outbox/offline_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('recovers model edits and other queued requests once', () async {
    final directory = await Directory.systemTemp.createTemp(
      'bicount_queue_test_',
    );
    addTearDown(() async {
      final resolved = path.normalize(directory.absolute.path);
      final temporaryRoot = path.normalize(Directory.systemTemp.absolute.path);
      if (!path.isWithin(temporaryRoot, resolved)) {
        throw StateError('Test directory escaped the temporary root.');
      }
      await directory.delete(recursive: true);
    });
    final factory = databaseFactoryFfi;
    final legacy = await factory.openDatabase(
      path.join(directory.path, 'my_repository.sqlite'),
    );
    await legacy.execute('CREATE TABLE UserModel (uid TEXT)');
    await legacy.insert('UserModel', {'uid': 'user-1'});
    await legacy.close();

    final queue = await factory.openDatabase(
      path.join(directory.path, 'brick_offline_queue.sqlite'),
    );
    await queue.execute(
      'CREATE TABLE HttpJobs ('
      'id INTEGER PRIMARY KEY, created_at INTEGER, request_method TEXT, '
      'url TEXT, body TEXT, headers TEXT)',
    );
    await queue.insert('HttpJobs', {
      'id': 1,
      'created_at': 1,
      'request_method': 'POST',
      'url': 'https://example.supabase.co/rest/v1/transactions?on_conflict=tid',
      'body': '{"tid":"row-1","amount":40}',
      'headers': '{}',
    });
    await queue.insert('HttpJobs', {
      'id': 2,
      'created_at': 2,
      'request_method': 'POST',
      'url': 'https://example.supabase.co/rest/v1/rpc/custom_action',
      'body': '{"id":"request-1"}',
      'headers': '{}',
    });
    await queue.insert('HttpJobs', {
      'id': 3,
      'created_at': 3,
      'request_method': 'DELETE',
      'url': 'https://example.supabase.co/rest/v1/transactions?tid=eq.row-3',
      'body': '',
      'headers': '{}',
    });
    final otherClaims = base64Url.encode(utf8.encode('{"sub":"user-2"}'));
    await queue.insert('HttpJobs', {
      'id': 4,
      'created_at': 4,
      'request_method': 'POST',
      'url': 'https://example.supabase.co/rest/v1/transactions',
      'body': '{"tid":"other-row","amount":99}',
      'headers': jsonEncode({
        'Authorization': 'Bearer header.$otherClaims.signature',
      }),
    });
    await queue.close();

    final target = await factory.openDatabase(
      path.join(directory.path, 'new.sqlite'),
    );
    addTearDown(target.close);
    await target.execute(
      'CREATE TABLE TransactionModel '
      '(tid TEXT PRIMARY KEY, amount REAL)',
    );
    await target.insert('TransactionModel', {'tid': 'row-1', 'amount': 40.0});
    final outbox = OfflineOutbox(target);
    await outbox.initialize();

    await importLegacyQueue(target, factory, 'user-1', directory.path);
    await importLegacyQueue(target, factory, 'user-1', directory.path);
    final pending = await outbox.pending('user-1');

    expect(pending, hasLength(3));
    expect(pending.first.action, 'upsert');
    expect(pending.first.recordId, 'row-1');
    expect(pending.first.payload['amount'], 40.0);
    expect(pending[1].action, 'legacy_http');
    expect(pending.last.action, 'delete');
    expect(pending.last.recordId, 'row-3');
  });

  test(
    'rewrites a queued funding request to the unified transactions table',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'bicount_legacy_job_',
      );
      addTearDown(() async {
        final resolved = path.normalize(directory.absolute.path);
        final temporaryRoot = path.normalize(
          Directory.systemTemp.absolute.path,
        );
        if (!path.isWithin(temporaryRoot, resolved)) {
          throw StateError('Test directory escaped the temporary root.');
        }
        await directory.delete(recursive: true);
      });
      final factory = databaseFactoryFfi;
      final legacy = await factory.openDatabase(
        path.join(directory.path, 'my_repository.sqlite'),
      );
      await legacy.execute('CREATE TABLE UserModel (uid TEXT)');
      await legacy.insert('UserModel', {'uid': 'user-1'});
      await legacy.close();
      final queue = await factory.openDatabase(
        path.join(directory.path, 'brick_offline_queue.sqlite'),
      );
      await queue.execute(
        'CREATE TABLE HttpJobs '
        '(id INTEGER PRIMARY KEY, created_at INTEGER, request_method TEXT, '
        'url TEXT, body TEXT, headers TEXT)',
      );
      await queue.insert('HttpJobs', {
        'id': 1,
        'created_at': 1,
        'request_method': 'POST',
        'url': 'https://example.supabase.co/rest/v1/account_funding',
        'body': '{"funding_id":"old-funding","amount":42}',
        'headers': '{}',
      });
      await queue.close();
      final target = await factory.openDatabase(
        path.join(directory.path, 'new.sqlite'),
      );
      addTearDown(target.close);
      await target.execute(
        'CREATE TABLE AccountFundingModel '
        '(funding_id TEXT, sid TEXT, amount REAL, currency TEXT, '
        'source TEXT, date TEXT, category INTEGER)',
      );
      await target.insert('AccountFundingModel', {
        'funding_id': 'old-funding',
        'sid': 'user-1',
        'amount': 42.0,
        'currency': 'USD',
        'source': 'Deposit',
        'date': '2026-04-01',
        'category': 0,
      });
      await OfflineOutbox(target).initialize();
      await importLegacyQueue(target, factory, 'user-1', directory.path);
      final pending = await OfflineOutbox(target).pending('user-1');
      expect(pending, hasLength(1));
      expect(pending.single.collection, 'transactions');
      expect(
        pending.single.recordId,
        canonicalLegacyUuid('account_funding', 'old-funding'),
      );
      expect(pending.single.payload['type'], 1);
    },
  );
}

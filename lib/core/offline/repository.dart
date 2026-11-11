import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/backend_environment.dart';
import 'offline_codecs.g.dart';
import 'offline_legacy_copy.dart';
import 'offline_legacy_finance_migration.dart';
import 'offline_legacy_import.dart';
import 'offline_legacy_owner.dart';
import 'offline_model.dart';
import 'offline_sync.dart';
import 'outbox/offline_operation.dart';
import 'outbox/offline_outbox.dart';

/// Local database and durable outgoing operations for one signed-in account.
class Repository {
  Repository._() : sqliteProvider = LocalSqliteProvider();

  static final Repository _instance = Repository._();
  factory Repository() => _instance;

  static late DatabaseFactory _factory;
  static Future<void> configure(DatabaseFactory factory) async {
    _factory = factory;
    BackendEnvironment.validate();
    await Supabase.initialize(
      url: BackendEnvironment.projectUrl,
      anonKey: BackendEnvironment.anonKey,
    );
  }

  final LocalSqliteProvider sqliteProvider;
  final Map<String, Future<Database>> _databases = {};
  final StreamController<Type> _changes = StreamController<Type>.broadcast();
  late final OfflineSync _sync = OfflineSync(this);
  bool legacyMigrationPending = false;

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;
  Stream<Type> get changes => _changes.stream;
  void notifyType(Type type) => _changes.add(type);

  Future<Database> database() async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) {
      throw StateError('An authenticated account is required for local data.');
    }
    return _databases.putIfAbsent(uid, () => _openFor(uid));
  }

  Future<(String, Database)> _writableDatabase() async {
    final uid = currentUserId;
    if (uid == null) {
      throw StateError('An authenticated account is required for local data.');
    }
    final db = await database();
    if (currentUserId != uid) {
      throw StateError(
        'The authenticated account changed during a local write.',
      );
    }
    return (uid, db);
  }

  Future<Database> _openFor(String uid) async {
    final directory = await _factory.getDatabasesPath();
    final target = path.join(
      directory,
      '${BackendEnvironment.isLocalPreproduction ? 'bicount_preprod_' : 'bicount_'}'
      '${uid.replaceAll('-', '')}.sqlite',
    );
    if (!BackendEnvironment.isLocalPreproduction &&
        !await _factory.databaseExists(target)) {
      await copyLegacyDatabaseForSameUser(_factory, uid, directory, target);
    }
    final db = await _factory.openDatabase(target);
    for (final codec in allOfflineCodecs) {
      final columns = codec.localColumns.values.toSet();
      final definitions = columns.map((name) => '"$name"').join(', ');
      await db.execute(
        'CREATE TABLE IF NOT EXISTS "${codec.localTable}" '
        '(_local_id INTEGER PRIMARY KEY AUTOINCREMENT, $definitions)',
      );
      final existing = await db.rawQuery(
        'PRAGMA table_info("${codec.localTable}")',
      );
      final names = existing.map((row) => row['name']).toSet();
      for (final column in columns.where((column) => !names.contains(column))) {
        await db.execute(
          'ALTER TABLE "${codec.localTable}" ADD COLUMN "$column"',
        );
      }
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS '
        '"bicount_${codec.localTable}_${codec.localKey}" '
        'ON "${codec.localTable}"("${codec.localKey}")',
      );
    }
    await OfflineOutbox(db).initialize();
    await db.execute(
      'CREATE TABLE IF NOT EXISTS bicount_removed_record_archive '
      '(table_name TEXT NOT NULL, record_id TEXT NOT NULL, '
      'payload TEXT NOT NULL, removed_at TEXT NOT NULL, '
      'PRIMARY KEY (table_name, record_id))',
    );
    try {
      if (!BackendEnvironment.isLocalPreproduction) {
        await migrateLegacyFinance(db, uid);
        await importLegacyQueue(db, _factory, uid, directory);
      } else {
        // Initialize the candidate table without importing a production queue.
        await migrateLegacyFinance(db, uid);
      }
      legacyMigrationPending = false;
    } catch (error) {
      legacyMigrationPending = true;
      debugPrint('Legacy offline queue requires recovery: $error');
    }
    return db;
  }

  Future<void> initialize() async {
    var activeUserId = currentUserId;
    if (currentUserId != null) {
      await database();
      unawaited(_sync.run());
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((_) async {
      final nextUserId = currentUserId;
      if (nextUserId != activeUserId) {
        activeUserId = nextUserId;
        await _sync.pause();
        if (nextUserId != null) {
          await _sync.run();
        }
      }
    });
    _sync.start();
  }

  Future<List<T>> get<T extends OfflineModel>({
    Query? query,
    OfflineReadPolicy policy = OfflineReadPolicy.localThenRemote,
  }) async {
    if (currentUserId == null) return <T>[];
    final items = await localGet<T>(query: query);
    if (policy == OfflineReadPolicy.localOnly || items.isNotEmpty) return items;
    try {
      // Start hydration, but never hold an offline screen behind a network timeout.
      await _sync.pull<T>().timeout(const Duration(milliseconds: 400));
      return localGet<T>(query: query);
    } catch (_) {
      return items;
    }
  }

  Future<List<T>> localGet<T extends OfflineModel>({Query? query}) async {
    final codec = codecFor<T>();
    final clauses = <String>[];
    final args = <Object?>[];
    for (final condition in query?.where ?? const <Where>[]) {
      final column = codec.localColumns[condition.field] ?? condition.field;
      if (!codec.localColumns.values.contains(column)) {
        throw ArgumentError.value(condition.field, 'field');
      }
      clauses.add('"$column" ${condition.value == null ? 'IS NULL' : '= ?'}');
      if (condition.value != null) args.add(condition.value);
    }
    final rows = await (await database()).query(
      codec.localTable,
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args,
    );
    return rows.map((row) => codec.fromLocal(row)).toList(growable: false);
  }

  Future<T> upsert<T extends OfflineModel>(
    T model, {
    bool isCreation = false,
  }) async {
    final codec = codecFor<T>();
    final local = codec.toLocal(model);
    final remote = codec.toRemote(model);
    final id = remote[codec.key]?.toString();
    if (id == null || id.isEmpty) throw StateError('Missing ${codec.key}');
    final (uid, db) = await _writableDatabase();
    final operation = OfflineOperation(
      userId: uid,
      collection: codec.table,
      recordId: id,
      action: 'upsert',
      payload: remote,
      isCreation: isCreation,
    );
    await OfflineOutbox(db).commit(operation, (tx) async {
      await tx.insert(
        codec.localTable,
        local,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    _changes.add(T);
    _sync.schedule();
    return model;
  }

  Future<void> delete<T extends OfflineModel>(T model) async {
    final codec = codecFor<T>();
    final id = codec.toRemote(model)[codec.key]?.toString();
    if (id == null || id.isEmpty) throw StateError('Missing ${codec.key}');
    final (uid, db) = await _writableDatabase();
    final operation = OfflineOperation(
      userId: uid,
      collection: codec.table,
      recordId: id,
      action: 'delete',
      payload: {codec.key: id},
    );
    await OfflineOutbox(db).commit(operation, (tx) async {
      await tx.delete(
        codec.localTable,
        where: '"${codec.localKey}" = ?',
        whereArgs: [id],
      );
    });
    _changes.add(T);
    _sync.schedule();
  }

  Future<void> queueRemoteUpsert({
    required String table,
    required String key,
    required String recordId,
    required Map<String, Object?> row,
    bool ignoreDuplicates = false,
  }) async {
    if (table.isEmpty ||
        key.isEmpty ||
        recordId.isEmpty ||
        row[key]?.toString() != recordId) {
      throw ArgumentError('A remote upsert needs a stable row identifier.');
    }
    final (uid, db) = await _writableDatabase();
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: table,
        recordId: recordId,
        action: 'remote_upsert',
        payload: {
          'key': key,
          'row': row,
          'ignore_duplicates': ignoreDuplicates,
        },
      ),
      (_) async {},
    );
    _sync.schedule();
  }

  Future<void> queueRemoteUpdate({
    required String table,
    required String recordId,
    required Map<String, Object?> filters,
    required Map<String, Object?> changes,
  }) async {
    if (table.isEmpty ||
        recordId.isEmpty ||
        filters.isEmpty ||
        changes.isEmpty) {
      throw ArgumentError('A remote update needs filters and changes.');
    }
    final (uid, db) = await _writableDatabase();
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: table,
        recordId: recordId,
        action: 'remote_update',
        payload: {'filters': filters, 'changes': changes},
      ),
      (_) async {},
    );
    _sync.schedule();
  }

  Future<void> queueFcmToken({
    required String userId,
    required Map<String, Object?> row,
  }) async {
    if (userId.isEmpty ||
        row['user_uid'] != userId ||
        currentUserId != userId) {
      throw ArgumentError('An FCM token needs its user identifier.');
    }
    final (uid, db) = await _writableDatabase();
    if (uid != userId) {
      throw StateError('The account changed before token persistence.');
    }
    await OfflineOutbox(db).commit(
      OfflineOperation(
        userId: uid,
        collection: 'fcm_tokens',
        recordId: userId,
        action: 'fcm_token',
        payload: row,
      ),
      (_) async {},
    );
    _sync.schedule();
  }

  Stream<List<T>> subscribeToRealtime<T extends OfflineModel>({
    Query? query,
  }) async* {
    _sync.watch<T>();
    yield await localGet<T>(query: query);
    yield* changes
        .where((type) => type == T)
        .asyncMap((_) => localGet<T>(query: query));
  }

  Future<void>
  notifySubscriptionsWithLocalData<T extends OfflineModel>() async {
    _changes.add(T);
  }

  Future<void> syncAllFromRemote() => _sync.run();
  Future<void> pauseRealtimeBindings() => _sync.pause();

  /// Account files remain isolated and durable across sign-out.
  Future<void> clearLocalSessionData() async => pauseRealtimeBindings();

  Future<void> purgeDeletedAccountData(String uid) async {
    if (currentUserId == uid) {
      throw StateError('Sign out before removing deleted account data.');
    }
    await _sync.pause();
    final open = _databases.remove(uid);
    if (open != null) await (await open).close();
    final directory = await _factory.getDatabasesPath();
    final target = path.join(
      directory,
      '${BackendEnvironment.isLocalPreproduction ? 'bicount_preprod_' : 'bicount_'}'
      '${uid.replaceAll('-', '')}.sqlite',
    );
    if (!path.isWithin(directory, target)) {
      throw StateError('Local database path escaped the app directory.');
    }
    for (final suffix in const ['', '-wal', '-shm', '-journal']) {
      final file = File('$target$suffix');
      if (await file.exists()) await file.delete();
    }
    final legacy = path.join(directory, 'my_repository.sqlite');
    if (!BackendEnvironment.isLocalPreproduction &&
        await legacyDatabaseBelongsTo(_factory, legacy, uid)) {
      for (final name in const [
        'my_repository.sqlite',
        'brick_offline_queue.sqlite',
      ]) {
        final source = path.join(directory, name);
        for (final suffix in const ['', '-wal', '-shm', '-journal']) {
          final file = File('$source$suffix');
          if (await file.exists()) await file.delete();
        }
      }
    }
  }
}

class LocalSqliteProvider {
  Future<T> upsert<T extends OfflineModel>(
    T model, {
    Repository? repository,
    bool queue = true,
  }) async {
    final repo = repository ?? Repository();
    if (queue) return repo.upsert<T>(model);
    final codec = codecFor<T>();
    await (await repo.database()).insert(
      codec.localTable,
      codec.toLocal(model),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await repo.notifySubscriptionsWithLocalData<T>();
    return model;
  }

  Future<void> delete<T extends OfflineModel>(
    T model, {
    Repository? repository,
  }) async {
    final repo = repository ?? Repository();
    final codec = codecFor<T>();
    final id = codec.toLocal(model)[codec.localKey];
    await (await repo.database()).delete(
      codec.localTable,
      where: '"${codec.localKey}" = ?',
      whereArgs: [id],
    );
    await repo.notifySubscriptionsWithLocalData<T>();
  }
}

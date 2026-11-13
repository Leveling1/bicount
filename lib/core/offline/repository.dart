import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bicount/features/wallet/data/data_sources/local_datasource/wallet_balance_store.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';

import '../constants/backend_environment.dart';
import 'offline_codecs.g.dart';
import 'offline_conflict_clock.dart';
import 'offline_legacy_copy.dart';
import 'offline_legacy_finance_migration.dart';
import 'offline_legacy_import.dart';
import 'offline_legacy_owner.dart';
import 'offline_model.dart';
import 'offline_model_schema.dart';
import 'offline_wallet_payload.dart';
import 'offline_sync.dart';
import 'outbox/offline_operation.dart';
import 'outbox/offline_outbox.dart';

/// Local database and durable outgoing operations for one signed-in account.
part 'offline_repository_wallet.dart';
part 'offline_repository_mutations.dart';
part 'offline_repository_account_data.dart';
part 'offline_repository_local_data.dart';

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
    await ensureOfflineModelSchema(db, allOfflineCodecs);
    if (BackendEnvironment.isLocalPreproduction) {
      await installWalletBalances(db, uid);
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
}

import 'dart:async';
import 'dart:convert';

import 'package:brick_core/query.dart';
import 'package:brick_offline_first/brick_offline_first.dart'
    show OfflineFirstGetPolicy;
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/memory_cache_provider.dart';
// This hide is for Brick's @Supabase annotation; in most cases,
// supabase_flutter **will not** be imported in application code.
import 'package:brick_supabase/brick_supabase.dart' hide Supabase;
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';
import 'package:bicount/features/group/data/models/group.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/project/data/models/project.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/secrets.dart';
import 'brick.g.dart';
import 'db/schema.g.dart';

class Repository extends OfflineFirstWithSupabaseRepository {
  static late Repository? _instance;
  static late DatabaseFactory _databaseFactory;
  static const _sqliteDatabaseName = 'my_repository.sqlite';
  static const _offlineQueueDatabaseName = 'brick_offline_queue.sqlite';
  static const _brickMigrationVersionsTableName = 'MigrationVersions';
  static const _recurringFundingSchemaVersion = 20260325165928;
  static const _currencyFxSchemaVersion = 20260329123000;
  static const _userReferenceCurrencySchemaVersion = 20260329194500;
  static const _salaryTrackingSchemaVersion = 20260331113000;
  static const _recurringTransfertSchemaVersion = 20260409080526;
  static final _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}$',
  );
  static final _legacyRecurringFundingIdRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}-'
    r'\d{8}$',
  );
  final Map<_RealtimeSubscriptionKey, _RealtimeBinding>
  _sharedRealtimeBindings = {};

  Repository._({
    required super.supabaseProvider,
    required super.sqliteProvider,
    required super.migrations,
    required super.offlineRequestQueue,
    super.memoryCacheProvider,
  });

  factory Repository() => _instance!;

  static Future<void> configure(DatabaseFactory databaseFactory) async {
    _databaseFactory = databaseFactory;
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      databaseFactory: databaseFactory,
    );

    await Supabase.initialize(
      url: Secrets.projectUrl,
      anonKey: Secrets.anonKey,
      httpClient: client,
    );

    final provider = SupabaseProvider(
      Supabase.instance.client,
      modelDictionary: supabaseModelDictionary,
    );

    _instance = Repository._(
      supabaseProvider: provider,
      sqliteProvider: SqliteProvider(
        _sqliteDatabaseName,
        databaseFactory: databaseFactory,
        modelDictionary: sqliteModelDictionary,
      ),
      migrations: migrations,
      offlineRequestQueue: queue,
      // Specify class types that should be cached in memory
      memoryCacheProvider: MemoryCacheProvider(),
    );
  }

  Future<void> repairCoreColumnsMigrationStateIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _sqliteDatabaseName,
    );
    final database = await _openRepairDatabase(databasePath);

    try {
      if (await _tableExists(database, 'UserModel')) {
        await _ensureColumn(
          database,
          tableName: 'UserModel',
          columnName: 'balance',
          definition: 'REAL',
        );
      }

      if (await _tableExists(database, 'FriendsModel')) {
        await _ensureColumn(
          database,
          tableName: 'FriendsModel',
          columnName: 'relation_type',
          definition: 'INTEGER',
        );
      }
    } finally {
      await database.close();
    }
  }

  Future<void> repairRecurringFundingMigrationStateIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _sqliteDatabaseName,
    );
    final database = await _openRepairDatabase(databasePath);

    try {
      if (!await _tableExists(database, 'AccountFundingModel')) {
        return;
      }

      final latestBrickMigrationVersion = await _lastBrickMigrationVersion(
        database,
      );
      final isRecurringFundingMigrationRecorded =
          latestBrickMigrationVersion >= _recurringFundingSchemaVersion;
      final hasFundingType = await _columnExists(
        database,
        'AccountFundingModel',
        'funding_type',
      );
      final hasRecurringFundingTable = await _tableExists(
        database,
        'RecurringFundingModel',
      );

      if (isRecurringFundingMigrationRecorded &&
          hasFundingType &&
          hasRecurringFundingTable) {
        return;
      }

      await _ensureColumn(
        database,
        tableName: 'AccountFundingModel',
        columnName: 'funding_type',
        definition: 'INTEGER',
      );
      await _ensureRecurringFundingTable(database);
      await _recordMigrationVersion(database, _recurringFundingSchemaVersion);
      await database.execute(
        'PRAGMA user_version = $_recurringFundingSchemaVersion',
      );
    } finally {
      await database.close();
    }
  }

  Future<void> repairCurrencyFxMigrationStateIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _sqliteDatabaseName,
    );
    final database = await _openRepairDatabase(databasePath);

    try {
      final tables = [
        'AccountFundingModel',
        'SubscriptionModel',
        'TransactionModel',
      ];
      if (!(await _tableExists(database, tables.first))) {
        return;
      }

      final latestBrickMigrationVersion = await _lastBrickMigrationVersion(
        database,
      );
      final isMigrationRecorded =
          latestBrickMigrationVersion >= _currencyFxSchemaVersion;
      final hasAllColumns = await _hasAllCurrencyFxColumns(database, tables);

      if (isMigrationRecorded && hasAllColumns) {
        return;
      }

      for (final table in tables) {
        await _ensureCurrencyFxColumns(database, table);
      }

      await _recordMigrationVersion(database, _currencyFxSchemaVersion);
      await database.execute('PRAGMA user_version = $_currencyFxSchemaVersion');
    } finally {
      await database.close();
    }
  }

  Future<void> repairUserReferenceCurrencyMigrationStateIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _sqliteDatabaseName,
    );
    final database = await _openRepairDatabase(databasePath);

    try {
      if (!await _tableExists(database, 'UserModel')) {
        return;
      }

      final latestBrickMigrationVersion = await _lastBrickMigrationVersion(
        database,
      );
      final isMigrationRecorded =
          latestBrickMigrationVersion >= _userReferenceCurrencySchemaVersion;
      final hasColumn = await _columnExists(
        database,
        'UserModel',
        'reference_currency_code',
      );

      if (isMigrationRecorded && hasColumn) {
        return;
      }

      await _ensureColumn(
        database,
        tableName: 'UserModel',
        columnName: 'reference_currency_code',
        definition: 'TEXT',
      );
      await _recordMigrationVersion(
        database,
        _userReferenceCurrencySchemaVersion,
      );
      await database.execute(
        'PRAGMA user_version = $_userReferenceCurrencySchemaVersion',
      );
    } finally {
      await database.close();
    }
  }

  Future<void> repairSalaryTrackingMigrationStateIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _sqliteDatabaseName,
    );
    final database = await _openRepairDatabase(databasePath);

    try {
      if (!await _tableExists(database, 'RecurringFundingModel')) {
        return;
      }

      final latestBrickMigrationVersion = await _lastBrickMigrationVersion(
        database,
      );
      final isMigrationRecorded =
          latestBrickMigrationVersion >= _salaryTrackingSchemaVersion;
      final hasProcessingMode = await _columnExists(
        database,
        'RecurringFundingModel',
        'salary_processing_mode',
      );
      final hasReminderStatus = await _columnExists(
        database,
        'RecurringFundingModel',
        'salary_reminder_status',
      );

      if (isMigrationRecorded && hasProcessingMode && hasReminderStatus) {
        return;
      }

      await _ensureColumn(
        database,
        tableName: 'RecurringFundingModel',
        columnName: 'salary_processing_mode',
        definition: 'INTEGER',
      );
      await _ensureColumn(
        database,
        tableName: 'RecurringFundingModel',
        columnName: 'salary_reminder_status',
        definition: 'INTEGER',
      );
      await _recordMigrationVersion(database, _salaryTrackingSchemaVersion);
      await database.execute(
        'PRAGMA user_version = $_salaryTrackingSchemaVersion',
      );
    } finally {
      await database.close();
    }
  }

  Future<void> repairRecurringTransfertMigrationStateIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _sqliteDatabaseName,
    );
    final database = await _openRepairDatabase(databasePath);

    try {
      if (!await _tableExists(database, 'TransactionModel')) {
        return;
      }

      final latestBrickMigrationVersion = await _lastBrickMigrationVersion(
        database,
      );
      final isMigrationRecorded =
          latestBrickMigrationVersion >= _recurringTransfertSchemaVersion;
      final hasRecurringTransfertId = await _columnExists(
        database,
        'TransactionModel',
        'recurring_transfert_id',
      );
      final hasRecurringOccurrenceDate = await _columnExists(
        database,
        'TransactionModel',
        'recurring_occurrence_date',
      );
      final hasGenerationMode = await _columnExists(
        database,
        'TransactionModel',
        'generation_mode',
      );
      final hasRecurringTransfertTable = await _tableExists(
        database,
        'RecurringTransfertModel',
      );
      final hasRecurringTransfertColumns = hasRecurringTransfertTable
          ? await _hasAllRecurringTransfertColumns(database)
          : false;

      if (isMigrationRecorded &&
          hasRecurringTransfertId &&
          hasRecurringOccurrenceDate &&
          hasGenerationMode &&
          hasRecurringTransfertTable &&
          hasRecurringTransfertColumns) {
        return;
      }

      await _ensureColumn(
        database,
        tableName: 'TransactionModel',
        columnName: 'recurring_transfert_id',
        definition: 'TEXT',
      );
      await _ensureColumn(
        database,
        tableName: 'TransactionModel',
        columnName: 'recurring_occurrence_date',
        definition: 'TEXT',
      );
      await _ensureColumn(
        database,
        tableName: 'TransactionModel',
        columnName: 'generation_mode',
        definition: 'INTEGER',
      );
      await _ensureRecurringTransfertTable(database);
      await _recordMigrationVersion(database, _recurringTransfertSchemaVersion);
      await database.execute(
        'PRAGMA user_version = $_recurringTransfertSchemaVersion',
      );
    } finally {
      await database.close();
    }
  }

  Future<void> repairLegacyOfflineQueueIfNeeded() async {
    final databasePath = path.join(
      await _databaseFactory.getDatabasesPath(),
      _offlineQueueDatabaseName,
    );
    final databaseExists = await _databaseFactory.databaseExists(databasePath);
    if (!databaseExists) {
      return;
    }

    final database = await _openRepairDatabase(databasePath);

    try {
      final tableRows = await database.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      );
      var deletedRequests = 0;

      for (final row in tableRows) {
        final tableName = row['name'] as String?;
        if (tableName == null || tableName.isEmpty) {
          continue;
        }
        deletedRequests += await _deleteLegacyOfflineQueueRows(
          database,
          tableName,
        );
      }

      if (deletedRequests > 0) {
        debugPrint(
          'Removed $deletedRequests legacy offline queue request(s) with '
          'invalid recurring account_funding ids.',
        );
      }
    } finally {
      await database.close();
    }
  }

  Future<void> clearLocalSessionData() async {
    await _disposeRealtimeBindings();

    for (final table in schema.tables) {
      await sqliteProvider.rawExecute('DELETE FROM `${table.name}`');
    }

    await _clearOfflineQueueRequests();

    memoryCacheProvider.reset();
  }

  Future<void> pauseRealtimeBindings() async {
    await _disposeRealtimeBindings();
  }

  @override
  Stream<List<TModel>>
  subscribeToRealtime<TModel extends OfflineFirstWithSupabaseModel>({
    PostgresChangeEvent eventType = PostgresChangeEvent.all,
    OfflineFirstGetPolicy policy = OfflineFirstGetPolicy.alwaysHydrate,
    Query? query,
    String schema = 'public',
  }) {
    final effectiveQuery = query ?? const Query();
    final key = _RealtimeSubscriptionKey(
      modelType: TModel,
      eventType: eventType,
      policy: policy,
      query: effectiveQuery,
      schema: schema,
    );
    final existingBinding = _sharedRealtimeBindings[key];
    if (existingBinding != null) {
      return existingBinding.subject.stream as Stream<List<TModel>>;
    }

    StreamSubscription<List<TModel>>? sourceSubscription;
    late final BehaviorSubject<List<TModel>> subject;

    subject = BehaviorSubject<List<TModel>>(
      onListen: () {
        sourceSubscription ??= super
            .subscribeToRealtime<TModel>(
              eventType: eventType,
              policy: policy,
              query: effectiveQuery,
              schema: schema,
            )
            .listen(
              (items) => subject.add(items),
              onError: (error, stackTrace) =>
                  subject.addError(error, stackTrace),
              onDone: () async {
                if (!subject.isClosed) {
                  await subject.close();
                }
                _sharedRealtimeBindings.remove(key);
              },
            );
      },
      onCancel: () async {
        if (subject.hasListener) {
          return;
        }

        final activeSubscription = sourceSubscription;
        sourceSubscription = null;
        await activeSubscription?.cancel();
        if (!subject.isClosed) {
          await subject.close();
        }
        _sharedRealtimeBindings.remove(key);
      },
    );

    _sharedRealtimeBindings[key] = _RealtimeBinding(
      subject: subject,
      cancelSource: () async {
        final activeSubscription = sourceSubscription;
        sourceSubscription = null;
        await activeSubscription?.cancel();
      },
    );
    return subject.stream;
  }

  Future<void> syncAllFromRemote() async {
    if (Supabase.instance.client.auth.currentSession == null) {
      return;
    }

    if (await _hasPendingOfflineRequests()) {
      debugPrint(
        'Skipping remote delete reconciliation because offline requests are still pending.',
      );
      return;
    }

    await Future.wait([
      _incrementalDeleteSync<UserModel>(uniqueValueOf: (model) => model.uid),
      _incrementalDeleteSync<FriendsModel>(uniqueValueOf: (model) => model.sid),
      _incrementalDeleteSync<TransactionModel>(
        uniqueValueOf: (model) => model.tid,
      ),
      _incrementalDeleteSync<RecurringTransfertModel>(
        uniqueValueOf: (model) => model.recurringTransfertId,
      ),
      _incrementalDeleteSync<CompanyModel>(uniqueValueOf: (model) => model.cid),
      _incrementalDeleteSync<CompanyWithUserLinkModel>(
        uniqueValueOf: (model) => model.lid,
      ),
      _incrementalDeleteSync<ProjectModel>(uniqueValueOf: (model) => model.pid),
      _incrementalDeleteSync<GroupModel>(uniqueValueOf: (model) => model.gid),
    ]);
  }

  Future<void> _incrementalDeleteSync<T extends OfflineFirstWithSupabaseModel>({
    required Object? Function(T model) uniqueValueOf,
  }) async {
    try {
      final localResults = await sqliteProvider.get<T>(repository: this);
      if (localResults.isEmpty) {
        return;
      }

      final remoteUniqueValues = await _fetchRemoteUniqueValues<T>();
      if (remoteUniqueValues == null) {
        return;
      }

      final toDelete = localResults.where((localModel) {
        final uniqueValue = uniqueValueOf(localModel);
        if (uniqueValue == null) {
          return false;
        }

        return !remoteUniqueValues.contains(uniqueValue);
      }).toList();

      if (toDelete.isEmpty) {
        return;
      }

      for (final deletableModel in toDelete) {
        await sqliteProvider.delete<T>(deletableModel, repository: this);
        memoryCacheProvider.delete<T>(deletableModel, repository: this);
      }

      await notifySubscriptionsWithLocalData<T>();
      debugPrint(
        'Reconciled ${toDelete.length} deleted item(s) for $T from remote state.',
      );
    } catch (error) {
      debugPrint('Delete reconciliation skipped for $T: $error');
    }
  }

  Future<Set<Object>?>
  _fetchRemoteUniqueValues<T extends OfflineFirstWithSupabaseModel>() async {
    final adapter = remoteProvider.modelDictionary.adapterFor[T];
    if (adapter == null || adapter.uniqueFields.isEmpty) {
      return null;
    }

    final uniqueField = adapter.uniqueFields.first;
    final supabaseColumn =
        adapter.fieldsToSupabaseColumns[uniqueField]?.columnName ?? uniqueField;
    const pageSize = 500;
    final values = <Object>{};
    var from = 0;

    while (true) {
      final rows =
          (await Supabase.instance.client
                  .from(adapter.supabaseTableName)
                  .select(supabaseColumn)
                  .range(from, from + pageSize - 1))
              as List<dynamic>;

      if (rows.isEmpty) {
        break;
      }

      for (final row in rows.cast<Map<String, dynamic>>()) {
        final value = row[supabaseColumn];
        if (value != null) {
          values.add(value as Object);
        }
      }

      if (rows.length < pageSize) {
        break;
      }
      from += pageSize;
    }

    return values;
  }

  Future<bool> _hasPendingOfflineRequests() async {
    try {
      final pendingRequests = await offlineRequestQueue.requestManager
          .unprocessedRequests();
      return pendingRequests.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _disposeRealtimeBindings() async {
    final bindings = _sharedRealtimeBindings.values.toList(growable: false);
    _sharedRealtimeBindings.clear();

    for (final binding in bindings) {
      await binding.cancelSource();
      if (!binding.subject.isClosed) {
        await binding.subject.close();
      }
    }
  }

  Future<void> _clearOfflineQueueRequests() async {
    try {
      final requestManager = offlineRequestQueue.requestManager;
      final queuedRequests = await requestManager.unprocessedRequests();
      final primaryKeyColumn = requestManager.primaryKeyColumn;

      for (final request in queuedRequests) {
        final rawId = request[primaryKeyColumn];
        final requestId = rawId is int ? rawId : int.tryParse('$rawId');
        if (requestId == null) {
          continue;
        }
        await requestManager.deleteUnprocessedRequest(requestId);
      }
    } catch (error) {
      debugPrint('Offline queue reset warning: $error');
    }
  }

  Future<void> _ensureRecurringFundingTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS `RecurringFundingModel` (
        `_brick_id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        `recurring_funding_id` TEXT,
        `uid` TEXT,
        `source` TEXT,
        `note` TEXT,
        `amount` REAL,
        `currency` TEXT,
        `funding_type` INTEGER,
        `frequency` INTEGER,
        `start_date` TEXT,
        `next_funding_date` TEXT,
        `last_processed_at` TEXT,
        `status` INTEGER,
        `salary_processing_mode` INTEGER,
        `salary_reminder_status` INTEGER,
        `created_at` TEXT
      )
    ''');

    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'recurring_funding_id',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'uid',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'source',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'note',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'amount',
      definition: 'REAL',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'currency',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'funding_type',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'frequency',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'start_date',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'next_funding_date',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'last_processed_at',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'status',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'salary_processing_mode',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'salary_reminder_status',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringFundingModel',
      columnName: 'created_at',
      definition: 'TEXT',
    );

    await database.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      '`index_RecurringFundingModel_on_recurring_funding_id` '
      'ON `RecurringFundingModel`(`recurring_funding_id`)',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS `index_RecurringFundingModel_on_uid` '
      'ON `RecurringFundingModel`(`uid`)',
    );
  }

  Future<void> _ensureRecurringTransfertTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS `RecurringTransfertModel` (
        `_brick_id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        `recurring_transfert_id` TEXT,
        `uid` TEXT,
        `transaction_type` INTEGER,
        `title` TEXT,
        `note` TEXT,
        `amount` REAL,
        `currency` TEXT,
        `sender_id` TEXT,
        `beneficiary_id` TEXT,
        `frequency` INTEGER,
        `start_date` TEXT,
        `next_due_date` TEXT,
        `end_date` TEXT,
        `status` INTEGER,
        `execution_mode` INTEGER,
        `reminder_enabled` INTEGER,
        `last_generated_at` TEXT,
        `last_confirmed_at` TEXT,
        `created_at` TEXT
      )
    ''');

    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'recurring_transfert_id',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'uid',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'transaction_type',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'title',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'note',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'amount',
      definition: 'REAL',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'currency',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'sender_id',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'beneficiary_id',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'frequency',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'start_date',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'next_due_date',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'end_date',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'status',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'execution_mode',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'reminder_enabled',
      definition: 'INTEGER',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'last_generated_at',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'last_confirmed_at',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: 'RecurringTransfertModel',
      columnName: 'created_at',
      definition: 'TEXT',
    );

    await database.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      '`index_RecurringTransfertModel_on_recurring_transfert_id` '
      'ON `RecurringTransfertModel`(`recurring_transfert_id`)',
    );
    await database.execute(
      'CREATE INDEX IF NOT EXISTS `index_RecurringTransfertModel_on_uid` '
      'ON `RecurringTransfertModel`(`uid`)',
    );
  }

  Future<void> _ensureCurrencyFxColumns(
    Database database,
    String tableName,
  ) async {
    await _ensureColumn(
      database,
      tableName: tableName,
      columnName: 'reference_currency_code',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: tableName,
      columnName: 'converted_amount',
      definition: 'REAL',
    );
    await _ensureColumn(
      database,
      tableName: tableName,
      columnName: 'amount_cdf',
      definition: 'REAL',
    );
    await _ensureColumn(
      database,
      tableName: tableName,
      columnName: 'rate_to_cdf',
      definition: 'REAL',
    );
    await _ensureColumn(
      database,
      tableName: tableName,
      columnName: 'fx_rate_date',
      definition: 'TEXT',
    );
    await _ensureColumn(
      database,
      tableName: tableName,
      columnName: 'fx_snapshot_id',
      definition: 'TEXT',
    );
  }

  Future<bool> _hasAllRecurringTransfertColumns(Database database) async {
    const columns = [
      'recurring_transfert_id',
      'uid',
      'transaction_type',
      'title',
      'note',
      'amount',
      'currency',
      'sender_id',
      'beneficiary_id',
      'frequency',
      'start_date',
      'next_due_date',
      'end_date',
      'status',
      'execution_mode',
      'reminder_enabled',
      'last_generated_at',
      'last_confirmed_at',
      'created_at',
    ];

    for (final column in columns) {
      if (!await _columnExists(database, 'RecurringTransfertModel', column)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _hasAllCurrencyFxColumns(
    Database database,
    List<String> tables,
  ) async {
    const columns = [
      'reference_currency_code',
      'converted_amount',
      'amount_cdf',
      'rate_to_cdf',
      'fx_rate_date',
      'fx_snapshot_id',
    ];

    for (final table in tables) {
      for (final column in columns) {
        if (!await _columnExists(database, table, column)) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _ensureMigrationVersionsTable(Database database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS '
      '$_brickMigrationVersionsTableName(version INTEGER PRIMARY KEY)',
    );
  }

  Future<Database> _openRepairDatabase(String databasePath) {
    return _databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
  }

  Future<void> _ensureColumn(
    Database database, {
    required String tableName,
    required String columnName,
    required String definition,
  }) async {
    if (await _columnExists(database, tableName, columnName)) {
      return;
    }

    await database.execute(
      'ALTER TABLE `$tableName` ADD `$columnName` $definition NULL',
    );
  }

  Future<bool> _tableExists(Database database, String tableName) async {
    final rows = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(
    Database database,
    String tableName,
    String columnName,
  ) async {
    final rows = await database.rawQuery('PRAGMA table_info(`$tableName`)');
    return rows.any((row) => row['name'] == columnName);
  }

  Future<int> _lastBrickMigrationVersion(Database database) async {
    await _ensureMigrationVersionsTable(database);
    final rows = await database.query(
      _brickMigrationVersionsTableName,
      orderBy: 'version DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return -1;
    }

    final rawVersion = rows.first['version'];
    return rawVersion is int ? rawVersion : int.tryParse('$rawVersion') ?? -1;
  }

  Future<void> _recordMigrationVersion(Database database, int version) async {
    await _ensureMigrationVersionsTable(database);
    await database.rawInsert(
      'INSERT OR IGNORE INTO $_brickMigrationVersionsTableName(version) '
      'VALUES(?)',
      [version],
    );
  }

  Future<int> _deleteLegacyOfflineQueueRows(
    Database database,
    String tableName,
  ) async {
    final columns = await database.rawQuery('PRAGMA table_info(`$tableName`)');
    if (columns.isEmpty) {
      return 0;
    }

    final columnNames = columns
        .map((column) => column['name'] as String?)
        .whereType<String>()
        .toSet();
    if (!columnNames.contains('body')) {
      return 0;
    }

    final primaryKeyColumn =
        columns.cast<Map<String, Object?>>().firstWhere(
              (column) => (column['pk'] as int? ?? 0) > 0,
              orElse: () => const {'name': 'id'},
            )['name']
            as String?;
    if (primaryKeyColumn == null || !columnNames.contains(primaryKeyColumn)) {
      return 0;
    }

    final rows = await database.query(
      tableName,
      columns: [primaryKeyColumn, 'body'],
    );
    final requestIdsToDelete = <Object?>[];

    for (final row in rows) {
      if (_isLegacyRecurringFundingQueueRow(row['body'])) {
        requestIdsToDelete.add(row[primaryKeyColumn]);
      }
    }

    if (requestIdsToDelete.isEmpty) {
      return 0;
    }

    await database.transaction((transaction) async {
      for (final requestId in requestIdsToDelete) {
        await transaction.delete(
          tableName,
          where: '`$primaryKeyColumn` = ?',
          whereArgs: [requestId],
        );
      }
    });

    return requestIdsToDelete.length;
  }

  bool _isLegacyRecurringFundingQueueRow(Object? rawBody) {
    if (rawBody is! String || rawBody.isEmpty) {
      return false;
    }

    final decodedBody = _decodeJsonMap(rawBody);
    if (decodedBody == null) {
      return false;
    }

    final fundingId = decodedBody['funding_id'];
    if (fundingId is! String || fundingId.isEmpty) {
      return false;
    }

    return _legacyRecurringFundingIdRegExp.hasMatch(fundingId) &&
        !_uuidRegExp.hasMatch(fundingId);
  }

  Map<String, dynamic>? _decodeJsonMap(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}

class _RealtimeBinding {
  const _RealtimeBinding({required this.subject, required this.cancelSource});

  final BehaviorSubject<dynamic> subject;
  final Future<void> Function() cancelSource;
}

class _RealtimeSubscriptionKey {
  const _RealtimeSubscriptionKey({
    required this.modelType,
    required this.eventType,
    required this.policy,
    required this.query,
    required this.schema,
  });

  final Type modelType;
  final PostgresChangeEvent eventType;
  final OfflineFirstGetPolicy policy;
  final Query query;
  final String schema;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _RealtimeSubscriptionKey &&
        other.modelType == modelType &&
        other.eventType == eventType &&
        other.policy == policy &&
        other.query == query &&
        other.schema == schema;
  }

  @override
  int get hashCode => Object.hash(modelType, eventType, policy, query, schema);
}

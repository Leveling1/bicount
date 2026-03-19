import 'dart:async';

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
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/project/data/models/project.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/secrets.dart';
import 'brick.g.dart';
import 'db/schema.g.dart';

class Repository extends OfflineFirstWithSupabaseRepository {
  static late Repository? _instance;
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
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      databaseFactory: databaseFactory,
    );

    await Supabase.initialize(
      url: Secrets.supabaseProjectUrl,
      anonKey: Secrets.supabaseAnonKey,
      httpClient: client,
    );

    final provider = SupabaseProvider(
      Supabase.instance.client,
      modelDictionary: supabaseModelDictionary,
    );

    _instance = Repository._(
      supabaseProvider: provider,
      sqliteProvider: SqliteProvider(
        'my_repository.sqlite',
        databaseFactory: databaseFactory,
        modelDictionary: sqliteModelDictionary,
      ),
      migrations: migrations,
      offlineRequestQueue: queue,
      // Specify class types that should be cached in memory
      memoryCacheProvider: MemoryCacheProvider(),
    );
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

    _sharedRealtimeBindings[key] = _RealtimeBinding(subject: subject);
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
      _incrementalDeleteSync<UserModel>(uniqueValueOf: (model) => model.sid),
      _incrementalDeleteSync<FriendsModel>(uniqueValueOf: (model) => model.sid),
      _incrementalDeleteSync<TransactionModel>(
        uniqueValueOf: (model) => model.tid,
      ),
      _incrementalDeleteSync<SubscriptionModel>(
        uniqueValueOf: (model) => model.subscriptionId,
      ),
      _incrementalDeleteSync<AccountFundingModel>(
        uniqueValueOf: (model) => model.fundingId,
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
}

class _RealtimeBinding {
  const _RealtimeBinding({required this.subject});

  final BehaviorSubject<dynamic> subject;
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

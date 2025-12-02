// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<SubscriptionModel> _$SubscriptionModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SubscriptionModel(
    subscriptionId: data['subscription_id'] == null
        ? null
        : data['subscription_id'] as String?,
    sid: data['sid'] as String,
    title: data['title'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    frequency: data['frequency'] as int,
    startDate: data['start_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    notes: data['notes'] == null ? null : data['notes'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    status: data['status'] == null ? null : data['status'] as int?,
  );
}

Future<Map<String, dynamic>> _$SubscriptionModelToSupabase(
  SubscriptionModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'subscription_id': instance.subscriptionId,
    'sid': instance.sid,
    'title': instance.title,
    'amount': instance.amount,
    'currency': instance.currency,
    'frequency': instance.frequency,
    'start_date': instance.startDate,
    'end_date': instance.endDate,
    'notes': instance.notes,
    'created_at': instance.createdAt,
    'status': instance.status,
  };
}

Future<SubscriptionModel> _$SubscriptionModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return SubscriptionModel(
    subscriptionId: data['subscription_id'] == null
        ? null
        : data['subscription_id'] as String?,
    sid: data['sid'] as String,
    title: data['title'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    frequency: data['frequency'] as int,
    startDate: data['start_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    notes: data['notes'] == null ? null : data['notes'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    status: data['status'] == null ? null : data['status'] as int?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$SubscriptionModelToSqlite(
  SubscriptionModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'subscription_id': instance.subscriptionId,
    'sid': instance.sid,
    'title': instance.title,
    'amount': instance.amount,
    'currency': instance.currency,
    'frequency': instance.frequency,
    'start_date': instance.startDate,
    'end_date': instance.endDate,
    'notes': instance.notes,
    'created_at': instance.createdAt,
    'status': instance.status,
  };
}

/// Construct a [SubscriptionModel]
class SubscriptionModelAdapter
    extends OfflineFirstWithSupabaseAdapter<SubscriptionModel> {
  SubscriptionModelAdapter();

  @override
  final supabaseTableName = 'subscriptions';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'subscriptionId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'subscription_id',
    ),
    'sid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sid',
    ),
    'title': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'title',
    ),
    'amount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'amount',
    ),
    'currency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'currency',
    ),
    'frequency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frequency',
    ),
    'startDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'start_date',
    ),
    'endDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'end_date',
    ),
    'notes': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'notes',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'status': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'status',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'subscriptionId'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'subscriptionId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'subscription_id',
      iterable: false,
      type: String,
    ),
    'sid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sid',
      iterable: false,
      type: String,
    ),
    'title': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'title',
      iterable: false,
      type: String,
    ),
    'amount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'amount',
      iterable: false,
      type: double,
    ),
    'currency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'currency',
      iterable: false,
      type: String,
    ),
    'frequency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'frequency',
      iterable: false,
      type: int,
    ),
    'startDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'start_date',
      iterable: false,
      type: String,
    ),
    'endDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'end_date',
      iterable: false,
      type: String,
    ),
    'notes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'notes',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: int,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    SubscriptionModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `SubscriptionModel` WHERE subscription_id = ? LIMIT 1''',
      [instance.subscriptionId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'SubscriptionModel';

  @override
  Future<SubscriptionModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SubscriptionModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    SubscriptionModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SubscriptionModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<SubscriptionModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SubscriptionModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    SubscriptionModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$SubscriptionModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

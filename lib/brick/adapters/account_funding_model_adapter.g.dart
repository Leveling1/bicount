// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<AccountFundingModel> _$AccountFundingModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return AccountFundingModel(
    fundingId: data['funding_id'] as String?,
    sid: data['sid'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    category: data['category'] as int,
    source: data['source'] as String,
    note: data['note'] == null ? null : data['note'] as String?,
    date: data['date'] as String,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
  );
}

Future<Map<String, dynamic>> _$AccountFundingModelToSupabase(
  AccountFundingModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'funding_id': instance.fundingId,
    'sid': instance.sid,
    'amount': instance.amount,
    'currency': instance.currency,
    'category': instance.category,
    'source': instance.source,
    'note': instance.note,
    'date': instance.date,
    'created_at': instance.createdAt,
  };
}

Future<AccountFundingModel> _$AccountFundingModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return AccountFundingModel(
    fundingId: data['funding_id'] as String,
    sid: data['sid'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    category: data['category'] as int,
    source: data['source'] as String,
    note: data['note'] == null ? null : data['note'] as String?,
    date: data['date'] as String,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$AccountFundingModelToSqlite(
  AccountFundingModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'funding_id': instance.fundingId,
    'sid': instance.sid,
    'amount': instance.amount,
    'currency': instance.currency,
    'category': instance.category,
    'source': instance.source,
    'note': instance.note,
    'date': instance.date,
    'created_at': instance.createdAt,
  };
}

/// Construct a [AccountFundingModel]
class AccountFundingModelAdapter
    extends OfflineFirstWithSupabaseAdapter<AccountFundingModel> {
  AccountFundingModelAdapter();

  @override
  final supabaseTableName = 'account_funding';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'fundingId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'funding_id',
    ),
    'sid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sid',
    ),
    'amount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'amount',
    ),
    'currency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'currency',
    ),
    'category': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'category',
    ),
    'source': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'source',
    ),
    'note': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'note',
    ),
    'date': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'date',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'fundingId'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'fundingId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'funding_id',
      iterable: false,
      type: String,
    ),
    'sid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sid',
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
    'category': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category',
      iterable: false,
      type: int,
    ),
    'source': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'source',
      iterable: false,
      type: String,
    ),
    'note': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'note',
      iterable: false,
      type: String,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    AccountFundingModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `AccountFundingModel` WHERE funding_id = ? LIMIT 1''',
      [instance.fundingId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'AccountFundingModel';

  @override
  Future<AccountFundingModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$AccountFundingModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    AccountFundingModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$AccountFundingModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<AccountFundingModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$AccountFundingModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    AccountFundingModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$AccountFundingModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

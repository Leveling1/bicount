// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<TransactionModel> _$TransactionModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return TransactionModel(
    gtid: data['gtid'] as String,
    uid: data['uid'] as String,
    name: data['name'] as String,
    type: data['type'] as String,
    beneficiaryId: data['beneficiary_id'] as String,
    senderId: data['sender_id'] as String,
    date: data['date'] as String,
    note: data['note'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    image: data['image'] == null ? null : data['image'] as String?,
    frequency: data['frequency'] == null ? null : data['frequency'] as String?,
    category: data['category'] == null ? null : data['category'] as int?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    tid: data['tid'] == null ? null : data['tid'] as String?,
  );
}

Future<Map<String, dynamic>> _$TransactionModelToSupabase(
  TransactionModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'gtid': instance.gtid,
    'uid': instance.uid,
    'name': instance.name,
    'type': instance.type,
    'beneficiary_id': instance.beneficiaryId,
    'sender_id': instance.senderId,
    'date': instance.date,
    'note': instance.note,
    'amount': instance.amount,
    'currency': instance.currency,
    'image': instance.image,
    'frequency': instance.frequency,
    'category': instance.category,
    'created_at': instance.createdAt,
    'tid': instance.tid,
  };
}

Future<TransactionModel> _$TransactionModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return TransactionModel(
    gtid: data['gtid'] as String,
    uid: data['uid'] as String,
    name: data['name'] as String,
    type: data['type'] as String,
    beneficiaryId: data['beneficiary_id'] as String,
    senderId: data['sender_id'] as String,
    date: data['date'] as String,
    note: data['note'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    image: data['image'] == null ? null : data['image'] as String?,
    frequency: data['frequency'] == null ? null : data['frequency'] as String?,
    category: data['category'] == null ? null : data['category'] as int?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    tid: data['tid'] == null ? null : data['tid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$TransactionModelToSqlite(
  TransactionModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'gtid': instance.gtid,
    'uid': instance.uid,
    'name': instance.name,
    'type': instance.type,
    'beneficiary_id': instance.beneficiaryId,
    'sender_id': instance.senderId,
    'date': instance.date,
    'note': instance.note,
    'amount': instance.amount,
    'currency': instance.currency,
    'image': instance.image,
    'frequency': instance.frequency,
    'category': instance.category,
    'created_at': instance.createdAt,
    'tid': instance.tid,
  };
}

/// Construct a [TransactionModel]
class TransactionModelAdapter
    extends OfflineFirstWithSupabaseAdapter<TransactionModel> {
  TransactionModelAdapter();

  @override
  final supabaseTableName = 'transactions';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'gtid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'gtid',
    ),
    'uid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'uid',
    ),
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'type': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'type',
    ),
    'beneficiaryId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'beneficiary_id',
    ),
    'senderId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sender_id',
    ),
    'date': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'date',
    ),
    'note': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'note',
    ),
    'amount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'amount',
    ),
    'currency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'currency',
    ),
    'image': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'image',
    ),
    'frequency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frequency',
    ),
    'category': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'category',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'tid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'tid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'tid'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'gtid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'gtid',
      iterable: false,
      type: String,
    ),
    'uid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'uid',
      iterable: false,
      type: String,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
    'type': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'type',
      iterable: false,
      type: String,
    ),
    'beneficiaryId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'beneficiary_id',
      iterable: false,
      type: String,
    ),
    'senderId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sender_id',
      iterable: false,
      type: String,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: String,
    ),
    'note': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'note',
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
    'image': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'image',
      iterable: false,
      type: String,
    ),
    'frequency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'frequency',
      iterable: false,
      type: String,
    ),
    'category': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'category',
      iterable: false,
      type: int,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
    'tid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'tid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    TransactionModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `TransactionModel` WHERE tid = ? LIMIT 1''',
      [instance.tid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'TransactionModel';

  @override
  Future<TransactionModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TransactionModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    TransactionModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TransactionModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<TransactionModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TransactionModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    TransactionModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$TransactionModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

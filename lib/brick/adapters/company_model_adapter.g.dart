// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<CompanyModel> _$CompanyModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return CompanyModel(
    name: data['name'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    image: data['image'] == null ? null : data['image'] as String?,
    sales: data['sales'] == null ? null : data['sales'] as double?,
    expenses: data['expenses'] == null ? null : data['expenses'] as double?,
    profit: data['profit'] == null ? null : data['profit'] as double?,
    salary: data['salary'] == null ? null : data['salary'] as double?,
    equipment: data['equipment'] == null ? null : data['equipment'] as double?,
    service: data['service'] == null ? null : data['service'] as double?,
    createdAt: data['created_at'] as String,
    cid: data['cid'] == null ? null : data['cid'] as String?,
  );
}

Future<Map<String, dynamic>> _$CompanyModelToSupabase(
  CompanyModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'name': instance.name,
    'description': instance.description,
    'image': instance.image,
    'sales': instance.sales,
    'expenses': instance.expenses,
    'profit': instance.profit,
    'salary': instance.salary,
    'equipment': instance.equipment,
    'service': instance.service,
    'created_at': instance.createdAt,
    'cid': instance.cid,
  };
}

Future<CompanyModel> _$CompanyModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return CompanyModel(
    name: data['name'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    image: data['image'] == null ? null : data['image'] as String?,
    sales: data['sales'] == null ? null : data['sales'] as double?,
    expenses: data['expenses'] == null ? null : data['expenses'] as double?,
    profit: data['profit'] == null ? null : data['profit'] as double?,
    salary: data['salary'] == null ? null : data['salary'] as double?,
    equipment: data['equipment'] == null ? null : data['equipment'] as double?,
    service: data['service'] == null ? null : data['service'] as double?,
    createdAt: data['created_at'] as String,
    cid: data['cid'] == null ? null : data['cid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CompanyModelToSqlite(
  CompanyModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'name': instance.name,
    'description': instance.description,
    'image': instance.image,
    'sales': instance.sales,
    'expenses': instance.expenses,
    'profit': instance.profit,
    'salary': instance.salary,
    'equipment': instance.equipment,
    'service': instance.service,
    'created_at': instance.createdAt,
    'cid': instance.cid,
  };
}

/// Construct a [CompanyModel]
class CompanyModelAdapter
    extends OfflineFirstWithSupabaseAdapter<CompanyModel> {
  CompanyModelAdapter();

  @override
  final supabaseTableName = 'companies';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'description': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description',
    ),
    'image': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'image',
    ),
    'sales': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sales',
    ),
    'expenses': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'expenses',
    ),
    'profit': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'profit',
    ),
    'salary': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'salary',
    ),
    'equipment': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'equipment',
    ),
    'service': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'service',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'cid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'cid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'cid'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
    'description': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'description',
      iterable: false,
      type: String,
    ),
    'image': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'image',
      iterable: false,
      type: String,
    ),
    'sales': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sales',
      iterable: false,
      type: double,
    ),
    'expenses': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'expenses',
      iterable: false,
      type: double,
    ),
    'profit': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'profit',
      iterable: false,
      type: double,
    ),
    'salary': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'salary',
      iterable: false,
      type: double,
    ),
    'equipment': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'equipment',
      iterable: false,
      type: double,
    ),
    'service': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'service',
      iterable: false,
      type: double,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
    'cid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'cid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    CompanyModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `CompanyModel` WHERE cid = ? LIMIT 1''',
      [instance.cid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'CompanyModel';

  @override
  Future<CompanyModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    CompanyModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<CompanyModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    CompanyModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

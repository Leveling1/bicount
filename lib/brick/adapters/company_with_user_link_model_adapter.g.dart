// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<CompanyWithUserLinkModel> _$CompanyWithUserLinkModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return CompanyWithUserLinkModel(
    companyId: data['company_id'] as String,
    userId: data['user_id'] as String,
    role: data['role'] as String,
    lid: data['lid'] == null ? null : data['lid'] as String?,
  );
}

Future<Map<String, dynamic>> _$CompanyWithUserLinkModelToSupabase(
  CompanyWithUserLinkModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'company_id': instance.companyId,
    'user_id': instance.userId,
    'role': instance.role,
    'lid': instance.lid,
  };
}

Future<CompanyWithUserLinkModel> _$CompanyWithUserLinkModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return CompanyWithUserLinkModel(
    companyId: data['company_id'] as String,
    userId: data['user_id'] as String,
    role: data['role'] as String,
    lid: data['lid'] == null ? null : data['lid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$CompanyWithUserLinkModelToSqlite(
  CompanyWithUserLinkModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'company_id': instance.companyId,
    'user_id': instance.userId,
    'role': instance.role,
    'lid': instance.lid,
  };
}

/// Construct a [CompanyWithUserLinkModel]
class CompanyWithUserLinkModelAdapter
    extends OfflineFirstWithSupabaseAdapter<CompanyWithUserLinkModel> {
  CompanyWithUserLinkModelAdapter();

  @override
  final supabaseTableName = 'company_with_user_link';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'companyId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'company_id',
    ),
    'userId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'user_id',
    ),
    'role': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'role',
    ),
    'lid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'lid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'lid'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'companyId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'company_id',
      iterable: false,
      type: String,
    ),
    'userId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'user_id',
      iterable: false,
      type: String,
    ),
    'role': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'role',
      iterable: false,
      type: String,
    ),
    'lid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    CompanyWithUserLinkModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `CompanyWithUserLinkModel` WHERE lid = ? LIMIT 1''',
      [instance.lid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'CompanyWithUserLinkModel';

  @override
  Future<CompanyWithUserLinkModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyWithUserLinkModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    CompanyWithUserLinkModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyWithUserLinkModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<CompanyWithUserLinkModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyWithUserLinkModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    CompanyWithUserLinkModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$CompanyWithUserLinkModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

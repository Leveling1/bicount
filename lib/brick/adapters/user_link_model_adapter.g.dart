// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UserLinkModel> _$UserLinkModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserLinkModel(
    userAId: data['user_a_id'] as String,
    userBId: data['user_b_id'] as String,
    linkType: data['link_type'] as String,
    status: data['status'] as String,
    lid: data['lid'] == null ? null : data['lid'] as String?,
  );
}

Future<Map<String, dynamic>> _$UserLinkModelToSupabase(
  UserLinkModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'user_a_id': instance.userAId,
    'user_b_id': instance.userBId,
    'link_type': instance.linkType,
    'status': instance.status,
    'lid': instance.lid,
  };
}

Future<UserLinkModel> _$UserLinkModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserLinkModel(
    userAId: data['user_a_id'] as String,
    userBId: data['user_b_id'] as String,
    linkType: data['link_type'] as String,
    status: data['status'] as String,
    lid: data['lid'] == null ? null : data['lid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserLinkModelToSqlite(
  UserLinkModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'user_a_id': instance.userAId,
    'user_b_id': instance.userBId,
    'link_type': instance.linkType,
    'status': instance.status,
    'lid': instance.lid,
  };
}

/// Construct a [UserLinkModel]
class UserLinkModelAdapter
    extends OfflineFirstWithSupabaseAdapter<UserLinkModel> {
  UserLinkModelAdapter();

  @override
  final supabaseTableName = 'user_links';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'userAId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'user_a_id',
    ),
    'userBId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'user_b_id',
    ),
    'linkType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'link_type',
    ),
    'status': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'status',
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
    'userAId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'user_a_id',
      iterable: false,
      type: String,
    ),
    'userBId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'user_b_id',
      iterable: false,
      type: String,
    ),
    'linkType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'link_type',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
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
    UserLinkModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `UserLinkModel` WHERE lid = ? LIMIT 1''',
      [instance.lid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'UserLinkModel';

  @override
  Future<UserLinkModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinkModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UserLinkModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinkModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UserLinkModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinkModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UserLinkModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinkModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

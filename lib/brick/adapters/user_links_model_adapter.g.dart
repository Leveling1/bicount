// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UserLinksModel> _$UserLinksModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserLinksModel(
    userAID: data['user_a_id'] as String,
    userBID: data['user_b_id'] as String,
    linkType: data['link_type'] as String,
    status: data['status'] as String,
    createAt: data['created_at'] == null ? null : data['created_at'] as String?,
    lid: data['lid'] == null ? null : data['lid'] as String?,
  );
}

Future<Map<String, dynamic>> _$UserLinksModelToSupabase(
  UserLinksModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'user_a_id': instance.userAID,
    'user_b_id': instance.userBID,
    'link_type': instance.linkType,
    'status': instance.status,
    'created_at': instance.createAt,
    'lid': instance.lid,
  };
}

Future<UserLinksModel> _$UserLinksModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserLinksModel(
    userAID: data['user_a_id'] as String,
    userBID: data['user_b_id'] as String,
    linkType: data['link_type'] as String,
    status: data['status'] as String,
    createAt: data['created_at'] == null ? null : data['created_at'] as String?,
    lid: data['lid'] == null ? null : data['lid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserLinksModelToSqlite(
  UserLinksModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'user_a_id': instance.userAID,
    'user_b_id': instance.userBID,
    'link_type': instance.linkType,
    'status': instance.status,
    'created_at': instance.createAt,
    'lid': instance.lid,
  };
}

/// Construct a [UserLinksModel]
class UserLinksModelAdapter
    extends OfflineFirstWithSupabaseAdapter<UserLinksModel> {
  UserLinksModelAdapter();

  @override
  final supabaseTableName = 'user_links';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'userAID': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'user_a_id',
    ),
    'userBID': const RuntimeSupabaseColumnDefinition(
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
    'createAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
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
    'userAID': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'user_a_id',
      iterable: false,
      type: String,
    ),
    'userBID': const RuntimeSqliteColumnDefinition(
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
    'createAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
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
    UserLinksModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `UserLinksModel` WHERE lid = ? LIMIT 1''',
      [instance.lid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'UserLinksModel';

  @override
  Future<UserLinksModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinksModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UserLinksModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinksModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UserLinksModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinksModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UserLinksModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserLinksModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

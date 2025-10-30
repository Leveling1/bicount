// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<GroupModel> _$GroupModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return GroupModel(
    cid: data['cid'] as String,
    name: data['name'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    image: data['image'] == null ? null : data['image'] as String?,
    number: data['number'] == null ? null : data['number'] as int?,
    createdAt: data['created_at'] as String,
    gid: data['gid'] == null ? null : data['gid'] as String?,
  );
}

Future<Map<String, dynamic>> _$GroupModelToSupabase(
  GroupModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'cid': instance.cid,
    'name': instance.name,
    'description': instance.description,
    'image': instance.image,
    'number': instance.number,
    'created_at': instance.createdAt,
    'gid': instance.gid,
  };
}

Future<GroupModel> _$GroupModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return GroupModel(
    cid: data['cid'] as String,
    name: data['name'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    image: data['image'] == null ? null : data['image'] as String?,
    number: data['number'] == null ? null : data['number'] as int?,
    createdAt: data['created_at'] as String,
    gid: data['gid'] == null ? null : data['gid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$GroupModelToSqlite(
  GroupModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'cid': instance.cid,
    'name': instance.name,
    'description': instance.description,
    'image': instance.image,
    'number': instance.number,
    'created_at': instance.createdAt,
    'gid': instance.gid,
  };
}

/// Construct a [GroupModel]
class GroupModelAdapter extends OfflineFirstWithSupabaseAdapter<GroupModel> {
  GroupModelAdapter();

  @override
  final supabaseTableName = 'groups';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'cid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'cid',
    ),
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
    'number': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'number',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'gid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'gid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'gid'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'cid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'cid',
      iterable: false,
      type: String,
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
    'number': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'number',
      iterable: false,
      type: int,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
    'gid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'gid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    GroupModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `GroupModel` WHERE gid = ? LIMIT 1''',
      [instance.gid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'GroupModel';

  @override
  Future<GroupModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$GroupModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    GroupModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$GroupModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<GroupModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$GroupModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    GroupModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$GroupModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

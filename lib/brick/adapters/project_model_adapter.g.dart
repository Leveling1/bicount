// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<ProjectModel> _$ProjectModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return ProjectModel(
    cid: data['cid'] as String,
    name: data['name'] as String,
    initiator: data['initiator'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    image: data['image'] == null ? null : data['image'] as String?,
    state: data['state'] == null ? null : data['state'] as int?,
    profit: data['profit'] == null ? null : data['profit'] as double?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    startDate: data['start_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    pid: data['pid'] == null ? null : data['pid'] as String?,
  );
}

Future<Map<String, dynamic>> _$ProjectModelToSupabase(
  ProjectModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'cid': instance.cid,
    'name': instance.name,
    'initiator': instance.initiator,
    'description': instance.description,
    'image': instance.image,
    'state': instance.state,
    'profit': instance.profit,
    'created_at': instance.createdAt,
    'start_date': instance.startDate,
    'end_date': instance.endDate,
    'pid': instance.pid,
  };
}

Future<ProjectModel> _$ProjectModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return ProjectModel(
    cid: data['cid'] as String,
    name: data['name'] as String,
    initiator: data['initiator'] as String,
    description: data['description'] == null
        ? null
        : data['description'] as String?,
    image: data['image'] == null ? null : data['image'] as String?,
    state: data['state'] == null ? null : data['state'] as int?,
    profit: data['profit'] == null ? null : data['profit'] as double?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    startDate: data['start_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    pid: data['pid'] == null ? null : data['pid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$ProjectModelToSqlite(
  ProjectModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'cid': instance.cid,
    'name': instance.name,
    'initiator': instance.initiator,
    'description': instance.description,
    'image': instance.image,
    'state': instance.state,
    'profit': instance.profit,
    'created_at': instance.createdAt,
    'start_date': instance.startDate,
    'end_date': instance.endDate,
    'pid': instance.pid,
  };
}

/// Construct a [ProjectModel]
class ProjectModelAdapter
    extends OfflineFirstWithSupabaseAdapter<ProjectModel> {
  ProjectModelAdapter();

  @override
  final supabaseTableName = 'projects';
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
    'initiator': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'initiator',
    ),
    'description': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'description',
    ),
    'image': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'image',
    ),
    'state': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'state',
    ),
    'profit': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'profit',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'startDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'start_date',
    ),
    'endDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'end_date',
    ),
    'pid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'pid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'pid'};
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
    'initiator': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'initiator',
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
    'state': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'state',
      iterable: false,
      type: int,
    ),
    'profit': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'profit',
      iterable: false,
      type: double,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
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
    'pid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'pid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    ProjectModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `ProjectModel` WHERE pid = ? LIMIT 1''',
      [instance.pid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'ProjectModel';

  @override
  Future<ProjectModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$ProjectModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    ProjectModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$ProjectModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<ProjectModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$ProjectModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    ProjectModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$ProjectModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

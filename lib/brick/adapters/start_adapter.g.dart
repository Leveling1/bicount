// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Start> _$StartFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Start(
    idUserLink: data['id_user_link'] as int,
    name: data['name'] as String,
    email: data['email'] == null ? null : data['email'] as String?,
    id: data['id'] as String?,
  );
}

Future<Map<String, dynamic>> _$StartToSupabase(
  Start instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id_user_link': instance.idUserLink,
    'name': instance.name,
    'email': instance.email,
    'id': instance.id,
  };
}

Future<Start> _$StartFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Start(
    idUserLink: data['id_user_link'] as int,
    name: data['name'] as String,
    email: data['email'] == null ? null : data['email'] as String?,
    id: data['id'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$StartToSqlite(
  Start instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id_user_link': instance.idUserLink,
    'name': instance.name,
    'email': instance.email,
    'id': instance.id,
  };
}

/// Construct a [Start]
class StartAdapter extends OfflineFirstWithSupabaseAdapter<Start> {
  StartAdapter();

  @override
  final supabaseTableName = 'start_data';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'idUserLink': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id_user_link',
    ),
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'email': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'email',
    ),
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'id'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'idUserLink': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id_user_link',
      iterable: false,
      type: int,
    ),
    'name': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'name',
      iterable: false,
      type: String,
    ),
    'email': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'email',
      iterable: false,
      type: String,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Start instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `Start` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Start';

  @override
  Future<Start> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$StartFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Start input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$StartToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Start> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$StartFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    Start input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$StartToSqlite(input, provider: provider, repository: repository);
}

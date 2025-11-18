// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<MemojiModel> _$MemojiModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return MemojiModel(
    name: data['name'] as String,
    link: data['link'] as String,
    sexe: data['sexe'] as String,
    mid: data['mid'] == null ? null : data['mid'] as String?,
  );
}

Future<Map<String, dynamic>> _$MemojiModelToSupabase(
  MemojiModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'name': instance.name,
    'link': instance.link,
    'sexe': instance.sexe,
    'mid': instance.mid,
  };
}

Future<MemojiModel> _$MemojiModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return MemojiModel(
    name: data['name'] as String,
    link: data['link'] as String,
    sexe: data['sexe'] as String,
    mid: data['mid'] == null ? null : data['mid'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$MemojiModelToSqlite(
  MemojiModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'name': instance.name,
    'link': instance.link,
    'sexe': instance.sexe,
    'mid': instance.mid,
  };
}

/// Construct a [MemojiModel]
class MemojiModelAdapter extends OfflineFirstWithSupabaseAdapter<MemojiModel> {
  MemojiModelAdapter();

  @override
  final supabaseTableName = 'memoji';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'link': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'link',
    ),
    'sexe': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sexe',
    ),
    'mid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'mid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'mid'};
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
    'link': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'link',
      iterable: false,
      type: String,
    ),
    'sexe': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sexe',
      iterable: false,
      type: String,
    ),
    'mid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'mid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    MemojiModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `MemojiModel` WHERE mid = ? LIMIT 1''',
      [instance.mid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'MemojiModel';

  @override
  Future<MemojiModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$MemojiModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    MemojiModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$MemojiModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<MemojiModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$MemojiModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    MemojiModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$MemojiModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<FriendsModel> _$FriendsModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return FriendsModel(
    uid: data['uid'] == null ? null : data['uid'] as String?,
    image: data['image'] as String,
    username: data['username'] as String,
    email: data['email'] as String,
    give: data['give'] == null ? null : data['give'] as double?,
    receive: data['receive'] == null ? null : data['receive'] as double?,
    sid: data['sid'] as String?,
  );
}

Future<Map<String, dynamic>> _$FriendsModelToSupabase(
  FriendsModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'uid': instance.uid,
    'image': instance.image,
    'username': instance.username,
    'email': instance.email,
    'give': instance.give,
    'receive': instance.receive,
    'sid': instance.sid,
  };
}

Future<FriendsModel> _$FriendsModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return FriendsModel(
    uid: data['uid'] == null ? null : data['uid'] as String?,
    image: data['image'] as String,
    username: data['username'] as String,
    email: data['email'] as String,
    give: data['give'] == null ? null : data['give'] as double?,
    receive: data['receive'] == null ? null : data['receive'] as double?,
    sid: data['sid'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$FriendsModelToSqlite(
  FriendsModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'uid': instance.uid,
    'image': instance.image,
    'username': instance.username,
    'email': instance.email,
    'give': instance.give,
    'receive': instance.receive,
    'sid': instance.sid,
  };
}

/// Construct a [FriendsModel]
class FriendsModelAdapter
    extends OfflineFirstWithSupabaseAdapter<FriendsModel> {
  FriendsModelAdapter();

  @override
  final supabaseTableName = 'friends';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'uid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'uid',
    ),
    'image': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'image',
    ),
    'username': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'username',
    ),
    'email': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'email',
    ),
    'give': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'give',
    ),
    'receive': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'receive',
    ),
    'sid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sid',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'sid'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'uid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'uid',
      iterable: false,
      type: String,
    ),
    'image': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'image',
      iterable: false,
      type: String,
    ),
    'username': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'username',
      iterable: false,
      type: String,
    ),
    'email': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'email',
      iterable: false,
      type: String,
    ),
    'give': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'give',
      iterable: false,
      type: double,
    ),
    'receive': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'receive',
      iterable: false,
      type: double,
    ),
    'sid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sid',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    FriendsModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `FriendsModel` WHERE sid = ? LIMIT 1''',
      [instance.sid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'FriendsModel';

  @override
  Future<FriendsModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FriendsModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    FriendsModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FriendsModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<FriendsModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FriendsModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    FriendsModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FriendsModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

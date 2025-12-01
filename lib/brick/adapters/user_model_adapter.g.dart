// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<UserModel> _$UserModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserModel(
    uid: data['uid'] as String,
    image: data['image'] as String,
    username: data['username'] as String,
    email: data['email'] as String,
    incomes: data['incomes'] == null ? null : data['incomes'] as double?,
    expenses: data['expenses'] == null ? null : data['expenses'] as double?,
    balance: data['profit'] == null ? null : data['profit'] as double?,
    companyIncome: data['company_income'] == null
        ? null
        : data['company_income'] as double?,
    personalIncome: data['personal_income'] == null
        ? null
        : data['personal_income'] as double?,
    sid: data['sid'] as String?,
  );
}

Future<Map<String, dynamic>> _$UserModelToSupabase(
  UserModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'uid': instance.uid,
    'image': instance.image,
    'username': instance.username,
    'email': instance.email,
    'incomes': instance.incomes,
    'expenses': instance.expenses,
    'profit': instance.balance,
    'company_income': instance.companyIncome,
    'personal_income': instance.personalIncome,
    'sid': instance.sid,
  };
}

Future<UserModel> _$UserModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return UserModel(
    uid: data['uid'] as String,
    image: data['image'] as String,
    username: data['username'] as String,
    email: data['email'] as String,
    incomes: data['incomes'] == null ? null : data['incomes'] as double?,
    expenses: data['expenses'] == null ? null : data['expenses'] as double?,
    balance: data['profit'] == null ? null : data['profit'] as double?,
    companyIncome: data['company_income'] == null
        ? null
        : data['company_income'] as double?,
    personalIncome: data['personal_income'] == null
        ? null
        : data['personal_income'] as double?,
    sid: data['sid'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserModelToSqlite(
  UserModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'uid': instance.uid,
    'image': instance.image,
    'username': instance.username,
    'email': instance.email,
    'incomes': instance.incomes,
    'expenses': instance.expenses,
    'profit': instance.balance,
    'company_income': instance.companyIncome,
    'personal_income': instance.personalIncome,
    'sid': instance.sid,
  };
}

/// Construct a [UserModel]
class UserModelAdapter extends OfflineFirstWithSupabaseAdapter<UserModel> {
  UserModelAdapter();

  @override
  final supabaseTableName = 'users';
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
    'incomes': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'incomes',
    ),
    'expenses': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'expenses',
    ),
    'profit': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'profit',
    ),
    'companyIncome': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'company_income',
    ),
    'personalIncome': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'personal_income',
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
    'incomes': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'incomes',
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
    'companyIncome': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'company_income',
      iterable: false,
      type: double,
    ),
    'personalIncome': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'personal_income',
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
    UserModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `UserModel` WHERE sid = ? LIMIT 1''',
      [instance.sid],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'UserModel';

  @override
  Future<UserModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    UserModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<UserModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    UserModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$UserModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

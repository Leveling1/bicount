// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<RecurringTransfertModel> _$RecurringTransfertModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return RecurringTransfertModel(
    recurringTransfertId: data['recurring_transfert_id'] == null
        ? null
        : data['recurring_transfert_id'] as String?,
    uid: data['uid'] as String,
    recurringTransfertTypeId: data['recurring_transfert_type_id'] as int,
    title: data['title'] as String,
    note: data['note'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    senderId: data['sender_id'] as String,
    beneficiaryId: data['beneficiary_id'] as String,
    frequency: data['frequency'] as int,
    startDate: data['start_date'] as String,
    nextDueDate: data['next_due_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    status: data['status'] as int,
    executionMode: data['execution_mode'] as int,
    reminderEnabled: data['reminder_enabled'] as bool,
    lastGeneratedAt: data['last_generated_at'] == null
        ? null
        : data['last_generated_at'] as String?,
    lastConfirmedAt: data['last_confirmed_at'] == null
        ? null
        : data['last_confirmed_at'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
  );
}

Future<Map<String, dynamic>> _$RecurringTransfertModelToSupabase(
  RecurringTransfertModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'recurring_transfert_id': instance.recurringTransfertId,
    'uid': instance.uid,
    'recurring_transfert_type_id': instance.recurringTransfertTypeId,
    'title': instance.title,
    'note': instance.note,
    'amount': instance.amount,
    'currency': instance.currency,
    'sender_id': instance.senderId,
    'beneficiary_id': instance.beneficiaryId,
    'frequency': instance.frequency,
    'start_date': instance.startDate,
    'next_due_date': instance.nextDueDate,
    'end_date': instance.endDate,
    'status': instance.status,
    'execution_mode': instance.executionMode,
    'reminder_enabled': instance.reminderEnabled,
    'last_generated_at': instance.lastGeneratedAt,
    'last_confirmed_at': instance.lastConfirmedAt,
    'created_at': instance.createdAt,
  };
}

Future<RecurringTransfertModel> _$RecurringTransfertModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return RecurringTransfertModel(
    recurringTransfertId: data['recurring_transfert_id'] == null
        ? null
        : data['recurring_transfert_id'] as String?,
    uid: data['uid'] as String,
    recurringTransfertTypeId: data['recurring_transfert_type_id'] as int,
    title: data['title'] as String,
    note: data['note'] as String,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    senderId: data['sender_id'] as String,
    beneficiaryId: data['beneficiary_id'] as String,
    frequency: data['frequency'] as int,
    startDate: data['start_date'] as String,
    nextDueDate: data['next_due_date'] as String,
    endDate: data['end_date'] == null ? null : data['end_date'] as String?,
    status: data['status'] as int,
    executionMode: data['execution_mode'] as int,
    reminderEnabled: data['reminder_enabled'] == 1,
    lastGeneratedAt: data['last_generated_at'] == null
        ? null
        : data['last_generated_at'] as String?,
    lastConfirmedAt: data['last_confirmed_at'] == null
        ? null
        : data['last_confirmed_at'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RecurringTransfertModelToSqlite(
  RecurringTransfertModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'recurring_transfert_id': instance.recurringTransfertId,
    'uid': instance.uid,
    'recurring_transfert_type_id': instance.recurringTransfertTypeId,
    'title': instance.title,
    'note': instance.note,
    'amount': instance.amount,
    'currency': instance.currency,
    'sender_id': instance.senderId,
    'beneficiary_id': instance.beneficiaryId,
    'frequency': instance.frequency,
    'start_date': instance.startDate,
    'next_due_date': instance.nextDueDate,
    'end_date': instance.endDate,
    'status': instance.status,
    'execution_mode': instance.executionMode,
    'reminder_enabled': instance.reminderEnabled ? 1 : 0,
    'last_generated_at': instance.lastGeneratedAt,
    'last_confirmed_at': instance.lastConfirmedAt,
    'created_at': instance.createdAt,
  };
}

/// Construct a [RecurringTransfertModel]
class RecurringTransfertModelAdapter
    extends OfflineFirstWithSupabaseAdapter<RecurringTransfertModel> {
  RecurringTransfertModelAdapter();

  @override
  final supabaseTableName = 'recurring_transfert';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'recurringTransfertId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'recurring_transfert_id',
    ),
    'uid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'uid',
    ),
    'recurringTransfertTypeId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'recurring_transfert_type_id',
    ),
    'title': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'title',
    ),
    'note': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'note',
    ),
    'amount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'amount',
    ),
    'currency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'currency',
    ),
    'senderId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'sender_id',
    ),
    'beneficiaryId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'beneficiary_id',
    ),
    'frequency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frequency',
    ),
    'startDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'start_date',
    ),
    'nextDueDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'next_due_date',
    ),
    'endDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'end_date',
    ),
    'status': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'status',
    ),
    'executionMode': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'execution_mode',
    ),
    'reminderEnabled': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'reminder_enabled',
    ),
    'lastGeneratedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'last_generated_at',
    ),
    'lastConfirmedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'last_confirmed_at',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'recurringTransfertId'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'recurringTransfertId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'recurring_transfert_id',
      iterable: false,
      type: String,
    ),
    'uid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'uid',
      iterable: false,
      type: String,
    ),
    'recurringTransfertTypeId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'recurring_transfert_type_id',
      iterable: false,
      type: int,
    ),
    'title': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'title',
      iterable: false,
      type: String,
    ),
    'note': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'note',
      iterable: false,
      type: String,
    ),
    'amount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'amount',
      iterable: false,
      type: double,
    ),
    'currency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'currency',
      iterable: false,
      type: String,
    ),
    'senderId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'sender_id',
      iterable: false,
      type: String,
    ),
    'beneficiaryId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'beneficiary_id',
      iterable: false,
      type: String,
    ),
    'frequency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'frequency',
      iterable: false,
      type: int,
    ),
    'startDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'start_date',
      iterable: false,
      type: String,
    ),
    'nextDueDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'next_due_date',
      iterable: false,
      type: String,
    ),
    'endDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'end_date',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: int,
    ),
    'executionMode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'execution_mode',
      iterable: false,
      type: int,
    ),
    'reminderEnabled': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reminder_enabled',
      iterable: false,
      type: bool,
    ),
    'lastGeneratedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_generated_at',
      iterable: false,
      type: String,
    ),
    'lastConfirmedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_confirmed_at',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    RecurringTransfertModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `RecurringTransfertModel` WHERE recurring_transfert_id = ? LIMIT 1''',
      [instance.recurringTransfertId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'RecurringTransfertModel';

  @override
  Future<RecurringTransfertModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringTransfertModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    RecurringTransfertModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringTransfertModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<RecurringTransfertModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringTransfertModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    RecurringTransfertModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringTransfertModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<RecurringFundingModel> _$RecurringFundingModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return RecurringFundingModel(
    recurringFundingId: data['recurring_funding_id'] as String?,
    uid: data['uid'] as String,
    source: data['source'] as String,
    note: data['note'] == null ? null : data['note'] as String?,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    fundingType: data['funding_type'] as int,
    frequency: data['frequency'] as int,
    startDate: data['start_date'] as String,
    nextFundingDate: data['next_funding_date'] as String,
    lastProcessedAt: data['last_processed_at'] == null
        ? null
        : data['last_processed_at'] as String?,
    status: data['status'] as int,
    salaryProcessingMode: data['salary_processing_mode'] == null
        ? SalaryProcessingMode.automatic
        : data['salary_processing_mode'] as int,
    salaryReminderStatus: data['salary_reminder_status'] == null
        ? SalaryReminderStatus.enabled
        : data['salary_reminder_status'] as int,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
  );
}

Future<Map<String, dynamic>> _$RecurringFundingModelToSupabase(
  RecurringFundingModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'recurring_funding_id': instance.recurringFundingId,
    'uid': instance.uid,
    'source': instance.source,
    'note': instance.note,
    'amount': instance.amount,
    'currency': instance.currency,
    'funding_type': instance.fundingType,
    'frequency': instance.frequency,
    'start_date': instance.startDate,
    'next_funding_date': instance.nextFundingDate,
    'last_processed_at': instance.lastProcessedAt,
    'status': instance.status,
    'salary_processing_mode': instance.salaryProcessingMode,
    'salary_reminder_status': instance.salaryReminderStatus,
    'created_at': instance.createdAt,
  };
}

Future<RecurringFundingModel> _$RecurringFundingModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return RecurringFundingModel(
    recurringFundingId: data['recurring_funding_id'] as String,
    uid: data['uid'] as String,
    source: data['source'] as String,
    note: data['note'] == null ? null : data['note'] as String?,
    amount: data['amount'] as double,
    currency: data['currency'] as String,
    fundingType: data['funding_type'] as int,
    frequency: data['frequency'] as int,
    startDate: data['start_date'] as String,
    nextFundingDate: data['next_funding_date'] as String,
    lastProcessedAt: data['last_processed_at'] == null
        ? null
        : data['last_processed_at'] as String?,
    status: data['status'] as int,
    salaryProcessingMode: data['salary_processing_mode'] == null
        ? SalaryProcessingMode.automatic
        : data['salary_processing_mode'] as int,
    salaryReminderStatus: data['salary_reminder_status'] == null
        ? SalaryReminderStatus.enabled
        : data['salary_reminder_status'] as int,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$RecurringFundingModelToSqlite(
  RecurringFundingModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'recurring_funding_id': instance.recurringFundingId,
    'uid': instance.uid,
    'source': instance.source,
    'note': instance.note,
    'amount': instance.amount,
    'currency': instance.currency,
    'funding_type': instance.fundingType,
    'frequency': instance.frequency,
    'start_date': instance.startDate,
    'next_funding_date': instance.nextFundingDate,
    'last_processed_at': instance.lastProcessedAt,
    'status': instance.status,
    'salary_processing_mode': instance.salaryProcessingMode,
    'salary_reminder_status': instance.salaryReminderStatus,
    'created_at': instance.createdAt,
  };
}

/// Construct a [RecurringFundingModel]
class RecurringFundingModelAdapter
    extends OfflineFirstWithSupabaseAdapter<RecurringFundingModel> {
  RecurringFundingModelAdapter();

  @override
  final supabaseTableName = 'recurring_fundings';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'recurringFundingId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'recurring_funding_id',
    ),
    'uid': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'uid',
    ),
    'source': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'source',
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
    'fundingType': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'funding_type',
    ),
    'frequency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'frequency',
    ),
    'startDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'start_date',
    ),
    'nextFundingDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'next_funding_date',
    ),
    'lastProcessedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'last_processed_at',
    ),
    'status': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'status',
    ),
    'salaryProcessingMode': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'salary_processing_mode',
    ),
    'salaryReminderStatus': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'salary_reminder_status',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'recurringFundingId'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'recurringFundingId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'recurring_funding_id',
      iterable: false,
      type: String,
    ),
    'uid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'uid',
      iterable: false,
      type: String,
    ),
    'source': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'source',
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
    'fundingType': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'funding_type',
      iterable: false,
      type: int,
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
    'nextFundingDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'next_funding_date',
      iterable: false,
      type: String,
    ),
    'lastProcessedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_processed_at',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: int,
    ),
    'salaryProcessingMode': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'salary_processing_mode',
      iterable: false,
      type: int,
    ),
    'salaryReminderStatus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'salary_reminder_status',
      iterable: false,
      type: int,
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
    RecurringFundingModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `RecurringFundingModel` WHERE recurring_funding_id = ? LIMIT 1''',
      [instance.recurringFundingId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'RecurringFundingModel';

  @override
  Future<RecurringFundingModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringFundingModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    RecurringFundingModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringFundingModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<RecurringFundingModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringFundingModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    RecurringFundingModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$RecurringFundingModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

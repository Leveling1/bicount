// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<DebtModel> _$DebtModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return DebtModel(
    debtId: data['debt_id'] == null ? null : data['debt_id'] as String?,
    createdBy: data['created_by'] as String,
    lenderId: data['lender_id'] as String,
    borrowerId: data['borrower_id'] as String,
    principalTransactionId: data['principal_transaction_id'] as String,
    title: data['title'] as String,
    note: data['note'] as String,
    currency: data['currency'] as String,
    principalAmount: data['principal_amount'] as double,
    expectedRepaymentAmount: data['expected_repayment_amount'] as double,
    expectedRepaymentCurrency: data['expected_repayment_currency'] == null
        ? null
        : data['expected_repayment_currency'] as String?,
    repaidAmount: data['repaid_amount'] as double,
    remainingAmount: data['remaining_amount'] as double,
    dueDate: data['due_date'] as String,
    status: data['status'] as int,
    reminderEnabled: data['reminder_enabled'] as bool,
    lastDueNotificationAt: data['last_due_notification_at'] == null
        ? null
        : data['last_due_notification_at'] as String?,
    closedAt: data['closed_at'] == null ? null : data['closed_at'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    updatedAt: data['updated_at'] == null
        ? null
        : data['updated_at'] as String?,
  );
}

Future<Map<String, dynamic>> _$DebtModelToSupabase(
  DebtModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'debt_id': instance.debtId,
    'created_by': instance.createdBy,
    'lender_id': instance.lenderId,
    'borrower_id': instance.borrowerId,
    'principal_transaction_id': instance.principalTransactionId,
    'title': instance.title,
    'note': instance.note,
    'currency': instance.currency,
    'principal_amount': instance.principalAmount,
    'expected_repayment_amount': instance.expectedRepaymentAmount,
    'expected_repayment_currency': instance.expectedRepaymentCurrency,
    'repaid_amount': instance.repaidAmount,
    'remaining_amount': instance.remainingAmount,
    'due_date': instance.dueDate,
    'status': instance.status,
    'reminder_enabled': instance.reminderEnabled,
    'last_due_notification_at': instance.lastDueNotificationAt,
    'closed_at': instance.closedAt,
    'created_at': instance.createdAt,
    'updated_at': instance.updatedAt,
  };
}

Future<DebtModel> _$DebtModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return DebtModel(
    debtId: data['debt_id'] == null ? null : data['debt_id'] as String?,
    createdBy: data['created_by'] as String,
    lenderId: data['lender_id'] as String,
    borrowerId: data['borrower_id'] as String,
    principalTransactionId: data['principal_transaction_id'] as String,
    title: data['title'] as String,
    note: data['note'] as String,
    currency: data['currency'] as String,
    principalAmount: data['principal_amount'] as double,
    expectedRepaymentAmount: data['expected_repayment_amount'] as double,
    expectedRepaymentCurrency: data['expected_repayment_currency'] == null
        ? null
        : data['expected_repayment_currency'] as String?,
    repaidAmount: data['repaid_amount'] as double,
    remainingAmount: data['remaining_amount'] as double,
    dueDate: data['due_date'] as String,
    status: data['status'] as int,
    reminderEnabled: data['reminder_enabled'] == 1,
    lastDueNotificationAt: data['last_due_notification_at'] == null
        ? null
        : data['last_due_notification_at'] as String?,
    closedAt: data['closed_at'] == null ? null : data['closed_at'] as String?,
    createdAt: data['created_at'] == null
        ? null
        : data['created_at'] as String?,
    updatedAt: data['updated_at'] == null
        ? null
        : data['updated_at'] as String?,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DebtModelToSqlite(
  DebtModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'debt_id': instance.debtId,
    'created_by': instance.createdBy,
    'lender_id': instance.lenderId,
    'borrower_id': instance.borrowerId,
    'principal_transaction_id': instance.principalTransactionId,
    'title': instance.title,
    'note': instance.note,
    'currency': instance.currency,
    'principal_amount': instance.principalAmount,
    'expected_repayment_amount': instance.expectedRepaymentAmount,
    'expected_repayment_currency': instance.expectedRepaymentCurrency,
    'repaid_amount': instance.repaidAmount,
    'remaining_amount': instance.remainingAmount,
    'due_date': instance.dueDate,
    'status': instance.status,
    'reminder_enabled': instance.reminderEnabled ? 1 : 0,
    'last_due_notification_at': instance.lastDueNotificationAt,
    'closed_at': instance.closedAt,
    'created_at': instance.createdAt,
    'updated_at': instance.updatedAt,
  };
}

/// Construct a [DebtModel]
class DebtModelAdapter extends OfflineFirstWithSupabaseAdapter<DebtModel> {
  DebtModelAdapter();

  @override
  final supabaseTableName = 'debts';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'debtId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'debt_id',
    ),
    'createdBy': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_by',
    ),
    'lenderId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'lender_id',
    ),
    'borrowerId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'borrower_id',
    ),
    'principalTransactionId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'principal_transaction_id',
    ),
    'title': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'title',
    ),
    'note': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'note',
    ),
    'currency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'currency',
    ),
    'principalAmount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'principal_amount',
    ),
    'expectedRepaymentAmount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'expected_repayment_amount',
    ),
    'expectedRepaymentCurrency': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'expected_repayment_currency',
    ),
    'repaidAmount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'repaid_amount',
    ),
    'remainingAmount': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'remaining_amount',
    ),
    'dueDate': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'due_date',
    ),
    'status': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'status',
    ),
    'reminderEnabled': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'reminder_enabled',
    ),
    'lastDueNotificationAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'last_due_notification_at',
    ),
    'closedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'closed_at',
    ),
    'createdAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'created_at',
    ),
    'updatedAt': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'updated_at',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'debtId'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'debtId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'debt_id',
      iterable: false,
      type: String,
    ),
    'createdBy': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_by',
      iterable: false,
      type: String,
    ),
    'lenderId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'lender_id',
      iterable: false,
      type: String,
    ),
    'borrowerId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'borrower_id',
      iterable: false,
      type: String,
    ),
    'principalTransactionId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'principal_transaction_id',
      iterable: false,
      type: String,
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
    'currency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'currency',
      iterable: false,
      type: String,
    ),
    'principalAmount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'principal_amount',
      iterable: false,
      type: double,
    ),
    'expectedRepaymentAmount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'expected_repayment_amount',
      iterable: false,
      type: double,
    ),
    'expectedRepaymentCurrency': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'expected_repayment_currency',
      iterable: false,
      type: String,
    ),
    'repaidAmount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'repaid_amount',
      iterable: false,
      type: double,
    ),
    'remainingAmount': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'remaining_amount',
      iterable: false,
      type: double,
    ),
    'dueDate': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'due_date',
      iterable: false,
      type: String,
    ),
    'status': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'status',
      iterable: false,
      type: int,
    ),
    'reminderEnabled': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'reminder_enabled',
      iterable: false,
      type: bool,
    ),
    'lastDueNotificationAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_due_notification_at',
      iterable: false,
      type: String,
    ),
    'closedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'closed_at',
      iterable: false,
      type: String,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: String,
    ),
    'updatedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'updated_at',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    DebtModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `DebtModel` WHERE debt_id = ? OR principal_transaction_id = ? LIMIT 1''',
      [instance.debtId, instance.principalTransactionId],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'DebtModel';

  @override
  Future<DebtModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DebtModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    DebtModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DebtModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<DebtModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DebtModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    DebtModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DebtModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}

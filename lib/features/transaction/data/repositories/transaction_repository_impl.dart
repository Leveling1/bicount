import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/offline/repository.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/offline_finance_local_service.dart';
import 'package:bicount/features/debt/data/data_sources/local_datasource/local_debt_data_source_impl.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../models/transaction.model.dart';
import 'transaction_party_resolution_service.dart';

part 'transaction_repository_create.dart';
part 'transaction_repository_update.dart';
part 'transaction_repository_artifacts.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl(
    this.localDataSource, {
    this.splitResolver = const TransactionSplitResolver(),
    DebtRepository? debtRepository,
    Future<void> Function(DebtModel debt)? saveDebt,
    Future<void> Function(String debtId)? deleteDebt,
    Future<void> Function(RecurringTransfertModel recurringTransfert)?
    saveRecurringTransfert,
  }) : _saveDebt = saveDebt ?? LocalDebtDataSourceImpl().createDebt,
       _deleteDebt = deleteDebt ?? LocalDebtDataSourceImpl().deleteDebt,
       _debtRepository = debtRepository,
       _saveRecurringTransfert =
           saveRecurringTransfert ??
           OfflineFinanceLocalService().createRecurringTransfert;

  final TransactionLocalDataSource localDataSource;
  final TransactionSplitResolver splitResolver;
  final Future<void> Function(DebtModel debt) _saveDebt;
  final Future<void> Function(String debtId) _deleteDebt;
  final DebtRepository? _debtRepository;
  final Future<void> Function(RecurringTransfertModel recurringTransfert)
  _saveRecurringTransfert;
  late final TransactionPartyResolutionService _partyResolutionService =
      TransactionPartyResolutionService(localDataSource);

  @override
  Future<void> createTransaction(
    CreateTransactionRequestEntity transaction,
  ) async => _createTransaction(transaction);

  @override
  Future<void> deleteTransaction(TransactionEntity transaction) async {
    try {
      final principalDebt = await _findPrincipalDebt(transaction);
      if (principalDebt != null && _debtRepository != null) {
        await _debtRepository.deleteDebtContract(principalDebt.debtId ?? '');
        return;
      }

      if (transaction.type == TransactionTypes.debtCode &&
          transaction.originId != null &&
          transaction.originId!.isNotEmpty &&
          _debtRepository != null) {
        await _debtRepository.deleteDebtLinkedTransaction(transaction);
        return;
      }

      final currentTransactions = await Repository().get<TransactionModel>(
        policy: OfflineReadPolicy.localOnly,
        query: Query(where: [Where.exact('tid', transaction.tid)]),
      );

      if (currentTransactions.isEmpty) {
        throw MessageFailure(
          message: 'Unable to delete this transaction right now.',
        );
      }

      await Repository().delete<TransactionModel>(currentTransactions.first);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to delete this transaction right now.',
      );
    }
  }

  @override
  Future<void> updateTransaction(
    TransactionEntity previousTransaction,
    CreateTransactionRequestEntity transaction,
  ) async => _updateTransaction(previousTransaction, transaction);

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }

  Future<TransactionModel?> _findStoredTransaction(String tid) async {
    if (tid.isEmpty) {
      return null;
    }

    try {
      final currentTransactions = await Repository().get<TransactionModel>(
        policy: OfflineReadPolicy.localOnly,
        query: Query(where: [Where.exact('tid', tid)]),
      );

      return currentTransactions.isEmpty ? null : currentTransactions.first;
    } catch (_) {
      return null;
    }
  }

  String? _authenticatedUserIdOrNull() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  Future<DebtModel?> _findPrincipalDebt(TransactionEntity transaction) async {
    if (_debtRepository == null) {
      return null;
    }

    return _debtRepository.findDebtByPrincipalTransactionId(transaction.tid);
  }

  int _resolvePartyTransactionType(CreateTransactionRequestEntity transaction) {
    if (transaction.isDebt) {
      return TransactionTypes.debtCode;
    }

    return transaction.recurringTypeId ?? transaction.transactionType;
  }

  bool _shouldSaveRecurringLedgerRows(
    CreateTransactionRequestEntity transaction,
  ) {
    return !_isRecurringSalary(transaction);
  }

  int _resolveRecurringExecutionMode(
    CreateTransactionRequestEntity transaction,
  ) {
    if (_isRecurringSalary(transaction)) {
      return AppExecutionMode.normalize(transaction.recurringExecutionMode);
    }

    return AppExecutionMode.manualConfirmation;
  }

  bool _resolveRecurringReminderEnabled(
    CreateTransactionRequestEntity transaction,
    int executionMode,
  ) {
    if (_isRecurringSalary(transaction) &&
        AppExecutionMode.isAutomatic(executionMode)) {
      return false;
    }

    return transaction.recurringReminderEnabled ?? true;
  }

  bool _isRecurringSalary(CreateTransactionRequestEntity transaction) {
    return transaction.isRecurring &&
        transaction.recurringTypeId == TransactionTypes.salaryCode;
  }
}

typedef _ResolvedParty = ResolvedTransactionParty;

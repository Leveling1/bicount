import 'package:bicount/core/offline/offline_model.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/debt/data/data_sources/local_datasource/debt_local_datasource.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:bicount/core/offline/repository.dart';

part 'debt_repository_currency.dart';

part 'debt_repository_permissions.dart';

part 'debt_repository_contract_edit.dart';

part 'debt_repository_repayment.dart';

part 'debt_repository_balance.dart';

const _amountTolerance = 0.000001;

class DebtRepositoryImpl implements DebtRepository {
  DebtRepositoryImpl(
    this.localDataSource,
    this.transactionLocalDataSource, {
    required CurrencyRepositoryImpl currencyRepository,
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  }) : _currencyRepository = currencyRepository;

  final DebtLocalDataSource localDataSource;
  final TransactionLocalDataSource transactionLocalDataSource;
  final TransactionParticipantIdentityService participantIdentityService;
  final CurrencyRepositoryImpl _currencyRepository;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<void> createDebt(DebtModel debt) {
    return localDataSource.createDebt(debt);
  }

  @override
  Future<void> deleteDebt(String debtId) {
    return deleteDebtContract(debtId);
  }

  @override
  Future<DebtModel?> findDebtById(String debtId) {
    return localDataSource.findDebtById(debtId);
  }

  @override
  Future<DebtModel?> findDebtByPrincipalTransactionId(
    String principalTransactionId,
  ) {
    return localDataSource.findDebtByPrincipalTransactionId(
      principalTransactionId,
    );
  }

  @override
  Future<void> updateDebtContract(UpdateDebtRequestEntity request) async =>
      _updateContract(request);

  @override
  Future<void> deleteDebtContract(String debtId) async {
    final debt = await localDataSource.findDebtById(debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    await _ensureCanManageContract(
      debt,
      failureMessage: 'Only the creator can delete this debt for now.',
    );

    final linkedTransactions = await _findLinkedTransactions(debt.debtId ?? '');
    for (final transaction in linkedTransactions) {
      await Repository().delete<TransactionModel>(transaction);
    }

    return localDataSource.deleteDebt(debtId);
  }

  @override
  Future<void> deleteDebtLinkedTransaction(
    TransactionEntity transaction,
  ) async {
    final principalDebt = await localDataSource
        .findDebtByPrincipalTransactionId(transaction.tid);
    if (principalDebt != null) {
      await deleteDebtContract(principalDebt.debtId ?? '');
      return;
    }

    final debtId = transaction.originId;
    if (debtId == null || debtId.isEmpty) {
      throw MessageFailure(message: 'Debt not found.');
    }

    final debt = await localDataSource.findDebtById(debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }

    await _deleteStoredTransaction(transaction.tid);
    final updatedDebt = await _rebuildDebtFromTransactions(debt);
    await localDataSource.updateDebt(updatedDebt);
  }

  @override
  Future<void> recordDebtPayment(
    RecordDebtPaymentRequestEntity request,
  ) async => _recordPayment(request);

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }

  Future<List<TransactionModel>> _findLinkedTransactions(String debtId) {
    return Repository().get<TransactionModel>(
      policy: OfflineReadPolicy.localOnly,
      query: Query(where: [Where.exact('originId', debtId)]),
    );
  }

  Future<TransactionModel?> _findTransactionById(String transactionId) async {
    if (transactionId.isEmpty) {
      return null;
    }

    final items = await Repository().get<TransactionModel>(
      policy: OfflineReadPolicy.localOnly,
      query: Query(where: [Where.exact('tid', transactionId)]),
    );
    return items.isEmpty ? null : items.first;
  }

  Future<void> _deleteStoredTransaction(String transactionId) async {
    final transaction = await _findTransactionById(transactionId);
    if (transaction == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    await Repository().delete<TransactionModel>(transaction);
  }
}

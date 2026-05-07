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
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../brick/repository.dart';

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
  static const _amountTolerance = 0.000001;

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
  Future<void> updateDebtContract(UpdateDebtRequestEntity request) async {
    final debt = await localDataSource.findDebtById(request.debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    await _ensureCanManageContract(
      debt,
      failureMessage: 'Only the creator can update this debt for now.',
    );

    final normalizedCurrency = CurrencyConfigEntity.normalizeCode(
      request.currency,
    );
    if (request.principalAmount <= 0 || request.expectedRepaymentAmount <= 0) {
      throw MessageFailure(message: 'Enter an amount greater than zero.');
    }
    if (request.dueDate.isEmpty) {
      throw MessageFailure(message: 'Debt due date is required.');
    }

    final principalTransaction = await _findTransactionById(
      debt.principalTransactionId,
    );
    if (principalTransaction == null) {
      throw MessageFailure(message: 'Debt not found.');
    }

    final provisionalDebt = DebtModel(
      debtId: debt.debtId,
      createdBy: debt.createdBy,
      lenderId: debt.lenderId,
      borrowerId: debt.borrowerId,
      principalTransactionId: debt.principalTransactionId,
      title: request.title,
      note: request.note,
      currency: normalizedCurrency,
      principalAmount: request.principalAmount,
      expectedRepaymentAmount: request.expectedRepaymentAmount,
      repaidAmount: debt.repaidAmount,
      remainingAmount: debt.remainingAmount,
      dueDate: request.dueDate,
      status: debt.status,
      reminderEnabled: debt.reminderEnabled,
      lastDueNotificationAt: debt.lastDueNotificationAt,
      closedAt: debt.closedAt,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    final repaidAmount = await _sumLinkedRepaymentsInDebtCurrency(
      provisionalDebt,
    );
    if (request.expectedRepaymentAmount + _amountTolerance < repaidAmount) {
      throw MessageFailure(
        message:
            'Expected repayment amount cannot be lower than the amount already repaid.',
      );
    }

    final updateResult = await transactionLocalDataSource.updateTransaction(
      TransactionEntity.fromTransaction(principalTransaction),
      title: request.title,
      type: principalTransaction.type,
      date: request.principalDate,
      amount: request.principalAmount,
      category: principalTransaction.category ?? Constants.personal,
      currency: normalizedCurrency,
      note: request.note,
      senderId: principalTransaction.senderId,
      beneficiaryId: principalTransaction.beneficiaryId,
      image: principalTransaction.image ?? Constants.memojiDefault,
    );
    await updateResult.fold(_throwFailure, (_) async => null);

    final remainingAmount =
        (request.expectedRepaymentAmount - repaidAmount).clamp(
              0,
              double.infinity,
            )
            as double;
    final updatedDebt = DebtModel(
      debtId: debt.debtId,
      createdBy: debt.createdBy,
      lenderId: debt.lenderId,
      borrowerId: debt.borrowerId,
      principalTransactionId: debt.principalTransactionId,
      title: request.title,
      note: request.note,
      currency: normalizedCurrency,
      principalAmount: request.principalAmount,
      expectedRepaymentAmount: request.expectedRepaymentAmount,
      repaidAmount: repaidAmount,
      remainingAmount: remainingAmount,
      dueDate: request.dueDate,
      status: _resolveStatus(provisionalDebt, remainingAmount),
      reminderEnabled: debt.reminderEnabled,
      lastDueNotificationAt: debt.lastDueNotificationAt,
      closedAt: remainingAmount == 0 ? DateTime.now().toIso8601String() : null,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await localDataSource.updateDebt(updatedDebt);
  }

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
  Future<void> recordDebtPayment(RecordDebtPaymentRequestEntity request) async {
    final debt = await localDataSource.findDebtById(request.debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    final requestCurrency = CurrencyConfigEntity.normalizeCode(
      request.currency,
    );
    if (request.amount <= 0 || requestCurrency.isEmpty) {
      throw MessageFailure(message: 'Enter a valid repayment amount.');
    }

    final debtCurrencyAmount = await _convertToDebtCurrency(
      amount: request.amount,
      originalCurrencyCode: requestCurrency,
      debtCurrencyCode: debt.currency,
    );

    if (debtCurrencyAmount > debt.remainingAmount + _amountTolerance) {
      throw MessageFailure(
        message: 'Repayment amount cannot exceed the remaining balance.',
      );
    }

    await _ensureCanRecordPayment(debt);

    final gtid = const Uuid().v4();
    final saveResult = await transactionLocalDataSource.saveTransaction(
      gtid,
      title: debt.title,
      type: TransactionTypes.debtCode,
      date: DateTime.now().toIso8601String(),
      amount: request.amount,
      category: Constants.personal,
      currency: requestCurrency,
      note: debt.note,
      senderId: debt.borrowerId,
      beneficiaryId: debt.lenderId,
      image: Constants.memojiDefault,
      originId: debt.debtId,
      generationMode: TransactionTypes.generationOneTime,
    );
    await saveResult.fold(_throwFailure, (_) async => null);

    final updatedDebt = await _rebuildDebtFromTransactions(debt);
    await localDataSource.updateDebt(updatedDebt);
  }

  Future<void> _ensureCanRecordPayment(DebtModel debt) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw AuthenticationFailure(message: 'Authentication failure');
    }

    final friends = await Repository().get<FriendsModel>(
      policy: OfflineFirstGetPolicy.localOnly,
    );
    final participantIds = participantIdentityService.currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: friends,
    );
    final bothLinkedToAccounts =
        _resolveAccountId(debt.lenderId, friends, currentUserId) != null &&
        _resolveAccountId(debt.borrowerId, friends, currentUserId) != null;

    if (bothLinkedToAccounts) {
      if (!participantIds.contains(debt.lenderId)) {
        throw MessageFailure(
          message: 'Only the lender can confirm received repayments.',
        );
      }
      return;
    }

    if (debt.createdBy != currentUserId) {
      throw MessageFailure(
        message: 'Only the creator can update this debt for now.',
      );
    }
  }

  Future<void> _ensureCanManageContract(
    DebtModel debt, {
    required String failureMessage,
  }) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw AuthenticationFailure(message: 'Authentication failure');
    }
    if (debt.createdBy != currentUserId) {
      throw MessageFailure(message: failureMessage);
    }
  }

  String? _resolveAccountId(
    String partyId,
    List<FriendsModel> friends,
    String currentUserId,
  ) {
    if (partyId == currentUserId) {
      return currentUserId;
    }

    for (final friend in friends) {
      if (friend.sid == partyId || friend.uid == partyId) {
        final linkedUid = friend.uid;
        if (linkedUid != null && linkedUid.isNotEmpty) {
          return linkedUid;
        }
        if (friend.sid == currentUserId) {
          return currentUserId;
        }
      }
    }

    return null;
  }

  Future<DebtModel> _rebuildDebtFromTransactions(DebtModel debt) async {
    final repaidAmount = await _sumLinkedRepaymentsInDebtCurrency(debt);

    final remainingAmount =
        (debt.expectedRepaymentAmount - repaidAmount).clamp(0, double.infinity)
            as double;
    final nextStatus = _resolveStatus(debt, remainingAmount);
    final closedAt = remainingAmount == 0
        ? DateTime.now().toIso8601String()
        : null;

    return DebtModel(
      debtId: debt.debtId,
      createdBy: debt.createdBy,
      lenderId: debt.lenderId,
      borrowerId: debt.borrowerId,
      principalTransactionId: debt.principalTransactionId,
      title: debt.title,
      note: debt.note,
      currency: debt.currency,
      principalAmount: debt.principalAmount,
      expectedRepaymentAmount: debt.expectedRepaymentAmount,
      repaidAmount: repaidAmount,
      remainingAmount: remainingAmount,
      dueDate: debt.dueDate,
      status: nextStatus,
      reminderEnabled: debt.reminderEnabled,
      lastDueNotificationAt: debt.lastDueNotificationAt,
      closedAt: closedAt,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  int _resolveStatus(DebtModel debt, double remainingAmount) {
    if (remainingAmount == 0) {
      return AppDebtState.paid;
    }

    final dueDate = DateTime.tryParse(debt.dueDate);
    final isOverdue =
        dueDate != null &&
        DateTime.now().isAfter(dueDate.add(const Duration(days: 1)));
    if (isOverdue) {
      return AppDebtState.overdue;
    }

    return repaidState(debt.expectedRepaymentAmount, remainingAmount);
  }

  int repaidState(double expectedAmount, double remainingAmount) {
    if (remainingAmount == expectedAmount) {
      return AppDebtState.active;
    }
    return AppDebtState.partial;
  }

  Future<T> _throwFailure<T>(Failure failure) async {
    throw failure;
  }

  Future<List<TransactionModel>> _findLinkedTransactions(String debtId) {
    return Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('originId', debtId)]),
    );
  }

  Future<TransactionModel?> _findTransactionById(String transactionId) async {
    if (transactionId.isEmpty) {
      return null;
    }

    final items = await Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
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

  Future<double> _sumLinkedRepaymentsInDebtCurrency(DebtModel debt) async {
    final linkedTransactions = await _findLinkedTransactions(debt.debtId ?? '');
    var repaidAmount = 0.0;
    for (final transaction in linkedTransactions) {
      if (transaction.tid == debt.principalTransactionId) {
        continue;
      }

      repaidAmount += await _convertTransactionToDebtCurrency(
        transaction,
        debtCurrencyCode: debt.currency,
      );
    }
    return repaidAmount;
  }

  Future<double> _convertToDebtCurrency({
    required double amount,
    required String originalCurrencyCode,
    required String debtCurrencyCode,
  }) async {
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      originalCurrencyCode,
    );
    final normalizedDebt = CurrencyConfigEntity.normalizeCode(debtCurrencyCode);
    if (normalizedOriginal == normalizedDebt) {
      return amount;
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: amount,
      originalCurrencyCode: normalizedOriginal,
    );
    return _convertCdfAmountToCurrency(
      amountCdf: quote.amountCdf,
      targetCurrencyCode: normalizedDebt,
      fxRateDate: quote.fxRateDate,
    );
  }

  Future<double> _convertTransactionToDebtCurrency(
    TransactionModel transaction, {
    required String debtCurrencyCode,
  }) async {
    final normalizedDebt = CurrencyConfigEntity.normalizeCode(debtCurrencyCode);
    final normalizedOriginal = CurrencyConfigEntity.normalizeCode(
      transaction.currency,
    );
    if (normalizedOriginal == normalizedDebt) {
      return transaction.amount;
    }

    final amountCdf =
        transaction.amountCdf ??
        await _resolveTransactionAmountCdf(transaction);
    return _convertCdfAmountToCurrency(
      amountCdf: amountCdf,
      targetCurrencyCode: normalizedDebt,
      fxRateDate: transaction.fxRateDate,
    );
  }

  Future<double> _resolveTransactionAmountCdf(
    TransactionModel transaction,
  ) async {
    final fxRateDate = transaction.fxRateDate;
    if (fxRateDate != null && fxRateDate.isNotEmpty) {
      final quote = await _currencyRepository.resolveHistoricalQuote(
        amount: transaction.amount,
        originalCurrencyCode: transaction.currency,
        rateDate: fxRateDate,
        referenceCurrencyCode:
            CurrencyConfigEntity.defaultReferenceCurrencyCode,
      );
      return quote.amountCdf;
    }

    final quote = await _currencyRepository.resolveCreationQuote(
      amount: transaction.amount,
      originalCurrencyCode: transaction.currency,
    );
    return quote.amountCdf;
  }

  Future<double> _convertCdfAmountToCurrency({
    required double amountCdf,
    required String targetCurrencyCode,
    String? fxRateDate,
  }) async {
    final normalizedTarget = CurrencyConfigEntity.normalizeCode(
      targetCurrencyCode,
    );
    if (normalizedTarget == CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return amountCdf;
    }

    final rateToCdf = await _resolveCurrencyRateToCdf(
      currencyCode: normalizedTarget,
      fxRateDate: fxRateDate,
    );
    if (rateToCdf == null || rateToCdf <= 0) {
      throw MessageFailure(
        message: 'Unable to load the latest exchange rates right now.',
      );
    }

    return amountCdf / rateToCdf;
  }

  Future<double?> _resolveCurrencyRateToCdf({
    required String currencyCode,
    String? fxRateDate,
  }) async {
    if (currencyCode == CurrencyConfigEntity.defaultReferenceCurrencyCode) {
      return 1;
    }

    if (fxRateDate != null && fxRateDate.isNotEmpty) {
      try {
        final quote = await _currencyRepository.resolveHistoricalQuote(
          amount: 1,
          originalCurrencyCode: currencyCode,
          rateDate: fxRateDate,
          referenceCurrencyCode:
              CurrencyConfigEntity.defaultReferenceCurrencyCode,
        );
        return quote.amountCdf;
      } on MessageFailure {
        rethrow;
      } catch (_) {}
    }

    try {
      final quote = await _currencyRepository.resolveCreationQuote(
        amount: 1,
        originalCurrencyCode: currencyCode,
      );
      return quote.amountCdf;
    } on MessageFailure {
      rethrow;
    } catch (_) {
      return _currencyRepository.currentConfig.latestRateToCdf(currencyCode);
    }
  }
}

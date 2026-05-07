import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/debt/data/data_sources/local_datasource/debt_local_datasource.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../brick/repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  DebtRepositoryImpl(
    this.localDataSource,
    this.transactionLocalDataSource, {
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  });

  final DebtLocalDataSource localDataSource;
  final TransactionLocalDataSource transactionLocalDataSource;
  final TransactionParticipantIdentityService participantIdentityService;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<void> createDebt(DebtModel debt) {
    return localDataSource.createDebt(debt);
  }

  @override
  Future<void> deleteDebt(String debtId) {
    return localDataSource.deleteDebt(debtId);
  }

  @override
  Future<void> recordDebtPayment(RecordDebtPaymentRequestEntity request) async {
    final debt = await localDataSource.findDebtById(request.debtId);
    if (debt == null) {
      throw MessageFailure(message: 'Debt not found.');
    }
    if (request.amount <= 0) {
      throw MessageFailure(message: 'Enter a valid repayment amount.');
    }
    if (request.amount > debt.remainingAmount) {
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
      currency: debt.currency,
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
    final linkedTransactions = await Repository().get<TransactionModel>(
      policy: OfflineFirstGetPolicy.localOnly,
      query: Query(where: [Where.exact('originId', debt.debtId)]),
    );

    final repaidAmount = linkedTransactions.fold<double>(0, (sum, transaction) {
      if (transaction.tid == debt.principalTransactionId) {
        return sum;
      }
      return sum + transaction.amount;
    });
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
}

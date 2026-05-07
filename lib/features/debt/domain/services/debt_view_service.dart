import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/debt_dashboard_entity.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:bicount/features/debt/domain/services/debt_permission_service.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

class DebtViewService {
  const DebtViewService({
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
    this.permissionService = const DebtPermissionService(),
  });

  final TransactionParticipantIdentityService participantIdentityService;
  final DebtPermissionService permissionService;

  DebtDashboardEntity build({
    required String currentUserId,
    required String currentUserName,
    required List<FriendsModel> friends,
    required List<DebtModel> debts,
  }) {
    final participantIds = participantIdentityService.currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: friends,
    );
    final receivable = <DebtSummaryEntity>[];
    final payable = <DebtSummaryEntity>[];

    for (final debt in debts) {
      if (!_isVisibleDebt(debt)) {
        continue;
      }

      final isReceivable = participantIds.contains(debt.lenderId);
      final isPayable = participantIds.contains(debt.borrowerId);
      if (!isReceivable && !isPayable) {
        continue;
      }

      final summary = DebtSummaryEntity(
        debt: debt,
        counterpartyName: _counterpartyName(
          debt: debt,
          friends: friends,
          currentUserId: currentUserId,
          currentUserName: currentUserName,
          isReceivable: isReceivable,
        ),
        isReceivable: isReceivable,
        canRecordPayment: permissionService.canRecordPayment(
          debt: debt,
          currentUserId: currentUserId,
          friends: friends,
        ),
        dueDate: DateTime.tryParse(debt.dueDate),
        isOverdue: AppDebtState.normalize(debt.status) == AppDebtState.overdue,
      );

      if (isReceivable) {
        receivable.add(summary);
      }
      if (isPayable) {
        payable.add(summary);
      }
    }

    receivable.sort(_compareSummary);
    payable.sort(_compareSummary);
    return DebtDashboardEntity(
      receivableDebts: receivable,
      payableDebts: payable,
    );
  }

  bool _isVisibleDebt(DebtModel debt) {
    return debt.remainingAmount > 0 && AppDebtState.isOpen(debt.status);
  }

  String _counterpartyName({
    required DebtModel debt,
    required List<FriendsModel> friends,
    required String currentUserId,
    required String currentUserName,
    required bool isReceivable,
  }) {
    final partyId = isReceivable ? debt.borrowerId : debt.lenderId;
    if (partyId == currentUserId) {
      return currentUserName;
    }

    for (final friend in friends) {
      if (friend.sid == partyId || friend.uid == partyId) {
        return friend.username;
      }
    }

    return partyId;
  }

  int _compareSummary(DebtSummaryEntity left, DebtSummaryEntity right) {
    final leftDate = left.dueDate ?? DateTime(9999);
    final rightDate = right.dueDate ?? DateTime(9999);
    final byDate = leftDate.compareTo(rightDate);
    if (byDate != 0) {
      return byDate;
    }

    return left.counterpartyName.compareTo(right.counterpartyName);
  }
}

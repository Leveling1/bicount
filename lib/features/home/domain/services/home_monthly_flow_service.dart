import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/home/domain/entities/home_monthly_flow_summary.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class HomeMonthlyFlowService {
  const HomeMonthlyFlowService({
    this.currencyAmountService = const CurrencyAmountService(),
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
  });

  final CurrencyAmountService currencyAmountService;
  final TransactionParticipantIdentityService participantIdentityService;

  HomeMonthlyFlowSummary build({
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
    DateTime? now,
  }) {
    final currentUserParticipantIds = participantIdentityService
        .currentUserParticipantIds(
          currentUserId: data.user.uid,
          friends: data.friends,
        );
    final referenceNow = now?.toLocal() ?? DateTime.now().toLocal();

    final currentStart = DateTime(referenceNow.year, referenceNow.month);
    final nextStart = DateTime(referenceNow.year, referenceNow.month + 1);
    final previousStart = DateTime(referenceNow.year, referenceNow.month - 1);

    var currentInflow = 0.0;
    var currentOutflow = 0.0;
    var previousInflow = 0.0;
    var previousOutflow = 0.0;

    for (final transaction in data.transactions) {
      final transactionDate = _parseLocalDate(transaction);
      if (transactionDate == null) {
        continue;
      }

      final amount = currencyAmountService.transaction(
        transaction,
        currencyConfig,
      );
      final isSender = currentUserParticipantIds.contains(transaction.senderId);
      final isBeneficiary = currentUserParticipantIds.contains(
        transaction.beneficiaryId,
      );

      if (_isInRange(
        value: transactionDate,
        startInclusive: currentStart,
        endExclusive: nextStart,
      )) {
        if (isBeneficiary) {
          currentInflow += amount;
        }
        if (isSender) {
          currentOutflow += amount;
        }
        continue;
      }

      if (_isInRange(
        value: transactionDate,
        startInclusive: previousStart,
        endExclusive: currentStart,
      )) {
        if (isBeneficiary) {
          previousInflow += amount;
        }
        if (isSender) {
          previousOutflow += amount;
        }
      }
    }

    final previousMonthNet = previousInflow - previousOutflow;
    final previousMonthCarryover = previousMonthNet > 0
        ? previousMonthNet
        : 0.0;

    return HomeMonthlyFlowSummary(
      currentMonthInflow: currentInflow,
      currentMonthOutflow: currentOutflow,
      previousMonthCarryover: previousMonthCarryover,
    );
  }

  DateTime? _parseLocalDate(TransactionModel transaction) {
    final parsed = DateTime.tryParse(transaction.date);
    return parsed?.toLocal();
  }

  bool _isInRange({
    required DateTime value,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    return !value.isBefore(startInclusive) && value.isBefore(endExclusive);
  }
}

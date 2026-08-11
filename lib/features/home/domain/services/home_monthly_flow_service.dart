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

    // Native amounts are accumulated per currency and converted once at the
    // end, exactly like the balance does. Converting each transaction
    // separately and then summing would drift, because two transactions in
    // the same currency can carry different historical rates.
    final currentInflowByCurrency = <String, double>{};
    final currentOutflowByCurrency = <String, double>{};
    final carryoverByCurrency = <String, double>{};

    for (final transaction in data.transactions) {
      final transactionDate = _parseLocalDate(transaction);
      if (transactionDate == null) {
        continue;
      }

      final currencyCode = CurrencyConfigEntity.normalizeCode(
        transaction.currency,
      );
      final amount = transaction.amount;
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
          _add(currentInflowByCurrency, currencyCode, amount);
        }
        if (isSender) {
          _add(currentOutflowByCurrency, currencyCode, amount);
        }
        continue;
      }

      // Everything before this month feeds the carry-over. Because it is
      // never clamped, this single bucket is mathematically identical to
      // chaining "previous month leftover" across every past month — and it
      // is what makes `inflowWithCarryover - outflow` land on the balance.
      if (transactionDate.isBefore(currentStart)) {
        if (isBeneficiary) {
          _add(carryoverByCurrency, currencyCode, amount);
        }
        if (isSender) {
          _add(carryoverByCurrency, currencyCode, -amount);
        }
      }
    }

    return HomeMonthlyFlowSummary(
      currentMonthInflow: _convertNetByCurrency(
        currentInflowByCurrency,
        currencyConfig,
      ),
      currentMonthOutflow: _convertNetByCurrency(
        currentOutflowByCurrency,
        currencyConfig,
      ),
      // Signed on purpose: a past deficit must stay visible instead of
      // being reset to zero.
      carryover: _convertNetByCurrency(carryoverByCurrency, currencyConfig),
    );
  }

  void _add(Map<String, double> byCurrency, String currencyCode, double delta) {
    byCurrency[currencyCode] = (byCurrency[currencyCode] ?? 0) + delta;
  }

  double _convertNetByCurrency(
    Map<String, double> nativeAmountsByCurrency,
    CurrencyConfigEntity currencyConfig,
  ) {
    var total = 0.0;
    for (final entry in nativeAmountsByCurrency.entries) {
      total += currencyAmountService.record(
        originalAmount: entry.value,
        originalCurrencyCode: entry.key,
        config: currencyConfig,
      );
    }
    return total;
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

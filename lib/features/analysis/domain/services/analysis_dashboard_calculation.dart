part of 'analysis_dashboard_builder.dart';

extension on AnalysisDashboardBuilder {
  AnalysisRecurringSummary _recurringSummary(
    RecurringPlanCollectionEntity collection,
  ) => AnalysisRecurringSummary(
    totalCount: collection.plans.length,
    activeCount: collection.activeCount,
    upcomingCount: collection.upcomingCount,
    monthlyReferenceAmount: collection.monthlyReferenceAmount,
    nextExpectedDate: collection.nextExpectedDate,
  );

  ({double total, double general, List<AnalysisBreakdownItem> contacts})
  _ordinaryBreakdown(
    List<TransactionModel> transactions,
    CurrencyConfigEntity currencyConfig,
    bool Function(TransactionModel) matches,
    AnalysisSourceData source,
    AnalysisChart chart,
  ) {
    final aliases = analysisContactAliases(source, chart);
    final amounts = <FriendsModel, double>{};
    var total = 0.0;
    var general = 0.0;

    for (final transaction in transactions.where(matches)) {
      final amount = currencyAmountService.transaction(
        transaction,
        currencyConfig,
      );
      total += amount;
      final friend =
          aliases[chart == AnalysisChart.income
              ? transaction.senderId
              : transaction.beneficiaryId];
      if (friend == null) {
        general += amount;
      } else {
        amounts.update(
          friend,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }
    final ordered = amounts.entries.toList()
      ..sort((left, right) => left.key.sid.compareTo(right.key.sid));
    return (
      total: total,
      general: general,
      contacts: [
        for (final entry in ordered)
          AnalysisBreakdownItem(
            label: entry.key.username,
            value: entry.value,
            friendSid: entry.key.sid,
          ),
      ],
    );
  }

  Set<String>? _resolveCurrentUserParticipantIds(AnalysisSourceData source) {
    final currentUserId = source.currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return null;
    }

    return participantIdentityService.currentUserParticipantIds(
      currentUserId: currentUserId,
      friends: source.friends,
    );
  }

  double _sumTransactions(
    List<TransactionModel> transactions,
    CurrencyConfigEntity currencyConfig,
    bool Function(TransactionModel transaction) predicate,
  ) {
    return transactions
        .where(predicate)
        .fold<double>(
          0,
          (sum, transaction) =>
              sum +
              currencyAmountService.transaction(transaction, currencyConfig),
        );
  }
}

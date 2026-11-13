part of 'analysis_dashboard_builder.dart';

extension on AnalysisDashboardBuilder {
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

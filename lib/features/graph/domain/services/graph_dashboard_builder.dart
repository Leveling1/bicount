import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/services/graph_time_series_builder.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class GraphDashboardBuilder {
  const GraphDashboardBuilder({
    this.timeSeriesBuilder = const GraphTimeSeriesBuilder(),
    this.currencyAmountService = const CurrencyAmountService(),
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
    this.recurringPlanCollectionBuilder =
        const RecurringPlanCollectionBuilder(),
  });

  final GraphTimeSeriesBuilder timeSeriesBuilder;
  final CurrencyAmountService currencyAmountService;
  final TransactionParticipantIdentityService participantIdentityService;
  final RecurringPlanCollectionBuilder recurringPlanCollectionBuilder;

  GraphDashboardEntity build(
    GraphSourceData source,
    GraphPeriod period,
    CurrencyConfigEntity currencyConfig,
  ) {
    final filteredTransactions = timeSeriesBuilder.filterTransactions(
      source.transactions,
      period,
    );
    final currentUserParticipantIds = _resolveCurrentUserParticipantIds(source);

    final incomeAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      (transaction) => _matchesGenericIncome(
        transaction,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
    );
    final salaryAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      (transaction) => _matchesSalary(
        transaction,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
    );
    final otherIncomeAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      (transaction) => _matchesOtherIncome(
        transaction,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
    );
    final expenseAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      (transaction) => _matchesGenericExpense(
        transaction,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
    );
    final subscriptionAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      (transaction) => _matchesSubscription(
        transaction,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
    );
    final otherExpenseAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      (transaction) => _matchesOtherExpense(
        transaction,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
    );

    final inflow = incomeAmount + salaryAmount + otherIncomeAmount;
    final outflow = expenseAmount + subscriptionAmount + otherExpenseAmount;
    final recurringCharges = recurringPlanCollectionBuilder.build(
      recurringTransferts: source.recurringTransferts,
      transactions: source.transactions,
      currencyConfig: currencyConfig,
      scope: RecurringPlanScope.charge,
    );
    final recurringIncomes = recurringPlanCollectionBuilder.build(
      recurringTransferts: source.recurringTransferts,
      transactions: source.transactions,
      currencyConfig: currencyConfig,
      scope: RecurringPlanScope.income,
    );

    return GraphDashboardEntity(
      period: period,
      displayCurrencyCode: currencyConfig.referenceCurrencyCode,
      inflow: inflow,
      outflow: outflow,
      netFlow: inflow - outflow,
      cashflowPoints: timeSeriesBuilder.buildCashflowPoints(
        filteredTransactions,
        period,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
      incomeBreakdown: [
        GraphBreakdownItem(label: 'Income', value: incomeAmount),
        GraphBreakdownItem(label: 'Salary', value: salaryAmount),
        GraphBreakdownItem(label: 'Other', value: otherIncomeAmount),
      ].where((item) => item.value > 0).toList(),
      expenseBreakdown: [
        GraphBreakdownItem(label: 'Expenses', value: expenseAmount),
        GraphBreakdownItem(label: 'Subscriptions', value: subscriptionAmount),
        GraphBreakdownItem(label: 'Other', value: otherExpenseAmount),
      ].where((item) => item.value > 0).toList(),
      recurringCharges: GraphRecurringSummary(
        totalCount: recurringCharges.plans.length,
        activeCount: recurringCharges.activeCount,
        upcomingCount: recurringCharges.upcomingCount,
        monthlyReferenceAmount: recurringCharges.monthlyReferenceAmount,
        nextExpectedDate: recurringCharges.nextExpectedDate,
      ),
      recurringIncomes: GraphRecurringSummary(
        totalCount: recurringIncomes.plans.length,
        activeCount: recurringIncomes.activeCount,
        upcomingCount: recurringIncomes.upcomingCount,
        monthlyReferenceAmount: recurringIncomes.monthlyReferenceAmount,
        nextExpectedDate: recurringIncomes.nextExpectedDate,
      ),
    );
  }

  Set<String>? _resolveCurrentUserParticipantIds(GraphSourceData source) {
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

  bool _matchesGenericIncome(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.beneficiaryId) &&
          transaction.type != TransactionTypes.salaryCode &&
          transaction.type != TransactionTypes.otherRecurringIncomeCode;
    }

    return transaction.type == TransactionTypes.incomeCode;
  }

  bool _matchesSalary(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.beneficiaryId) &&
          transaction.type == TransactionTypes.salaryCode;
    }

    return transaction.type == TransactionTypes.salaryCode;
  }

  bool _matchesOtherIncome(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.beneficiaryId) &&
          transaction.type == TransactionTypes.otherRecurringIncomeCode;
    }

    return transaction.type == TransactionTypes.otherRecurringIncomeCode;
  }

  bool _matchesGenericExpense(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.senderId) &&
          transaction.type != TransactionTypes.subscriptionCode &&
          transaction.type != TransactionTypes.otherRecurringExpenseCode;
    }

    return transaction.type == TransactionTypes.expenseCode;
  }

  bool _matchesSubscription(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.senderId) &&
          transaction.type == TransactionTypes.subscriptionCode;
    }

    return transaction.type == TransactionTypes.subscriptionCode;
  }

  bool _matchesOtherExpense(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.senderId) &&
          transaction.type == TransactionTypes.otherRecurringExpenseCode;
    }

    return transaction.type == TransactionTypes.otherRecurringExpenseCode ||
        transaction.type == TransactionTypes.othersCode;
  }
}

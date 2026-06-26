import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_debt_balance_resolver.dart';
import 'package:bicount/features/analysis/domain/services/analysis_debt_transaction_classifier.dart';
import 'package:bicount/features/analysis/domain/services/analysis_time_series_builder.dart';
import 'package:bicount/features/analysis/domain/services/analysis_transaction_breakdown_matcher.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class AnalysisDashboardBuilder {
  const AnalysisDashboardBuilder({
    this.timeSeriesBuilder = const AnalysisTimeSeriesBuilder(),
    this.currencyAmountService = const CurrencyAmountService(),
    this.participantIdentityService =
        const TransactionParticipantIdentityService(),
    this.recurringPlanCollectionBuilder =
        const RecurringPlanCollectionBuilder(),
  });

  final AnalysisTimeSeriesBuilder timeSeriesBuilder;
  final CurrencyAmountService currencyAmountService;
  final TransactionParticipantIdentityService participantIdentityService;
  final RecurringPlanCollectionBuilder recurringPlanCollectionBuilder;

  AnalysisDashboardEntity build(
    AnalysisSourceData source,
    AnalysisPeriod period,
    CurrencyConfigEntity currencyConfig,
  ) {
    final filteredTransactions = timeSeriesBuilder.filterTransactions(
      source.transactions,
      period,
    );
    final currentUserParticipantIds = _resolveCurrentUserParticipantIds(source);
    final debtClassifier = AnalysisDebtTransactionClassifier(source.debts);
    final debtBalanceResolver = AnalysisDebtBalanceResolver(
      currentUserParticipantIds: currentUserParticipantIds,
      currencyAmountService: currencyAmountService,
    );
    final matcher = AnalysisTransactionBreakdownMatcher(
      debtClassifier: debtClassifier,
      currentUserParticipantIds: currentUserParticipantIds,
    );

    final incomeAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesGenericIncome,
    );
    final salaryAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesSalary,
    );
    final debtIncomeAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesDebtIncome,
    );
    final debtRepaymentIncomeAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesDebtRepaymentIncome,
    );
    final otherIncomeAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesOtherIncome,
    );
    final expenseAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesGenericExpense,
    );
    final subscriptionAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesSubscription,
    );
    final debtExpenseAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesDebtExpense,
    );
    final debtRepaymentExpenseAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesDebtRepaymentExpense,
    );
    final otherExpenseAmount = _sumTransactions(
      filteredTransactions,
      currencyConfig,
      matcher.matchesOtherExpense,
    );

    final inflow =
        incomeAmount +
        salaryAmount +
        debtIncomeAmount +
        debtRepaymentIncomeAmount +
        otherIncomeAmount;
    final outflow =
        expenseAmount +
        subscriptionAmount +
        debtExpenseAmount +
        debtRepaymentExpenseAmount +
        otherExpenseAmount;
    final receivableDebt = debtBalanceResolver.receivableBalance(
      source.debts,
      currencyConfig,
    );
    final payableDebt = debtBalanceResolver.payableBalance(
      source.debts,
      currencyConfig,
    );
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

    return AnalysisDashboardEntity(
      period: period,
      displayCurrencyCode: currencyConfig.referenceCurrencyCode,
      inflow: inflow,
      outflow: outflow,
      netFlow: inflow - outflow,
      receivableDebt: receivableDebt,
      payableDebt: payableDebt,
      cashflowPoints: timeSeriesBuilder.buildCashflowPoints(
        filteredTransactions,
        period,
        currentUserParticipantIds: currentUserParticipantIds,
      ),
      incomeBreakdown: [
        AnalysisBreakdownItem(label: 'Income', value: incomeAmount),
        AnalysisBreakdownItem(label: 'Salary', value: salaryAmount),
        AnalysisBreakdownItem(label: 'Debt', value: debtIncomeAmount),
        AnalysisBreakdownItem(
          label: 'Repayments',
          value: debtRepaymentIncomeAmount,
        ),
        AnalysisBreakdownItem(label: 'Other', value: otherIncomeAmount),
      ].where((item) => item.value > 0).toList(),
      expenseBreakdown: [
        AnalysisBreakdownItem(label: 'Expenses', value: expenseAmount),
        AnalysisBreakdownItem(
          label: 'Subscriptions',
          value: subscriptionAmount,
        ),
        AnalysisBreakdownItem(label: 'Debt', value: debtExpenseAmount),
        AnalysisBreakdownItem(
          label: 'Repayments',
          value: debtRepaymentExpenseAmount,
        ),
        AnalysisBreakdownItem(label: 'Other', value: otherExpenseAmount),
      ].where((item) => item.value > 0).toList(),
      recurringCharges: AnalysisRecurringSummary(
        totalCount: recurringCharges.plans.length,
        activeCount: recurringCharges.activeCount,
        upcomingCount: recurringCharges.upcomingCount,
        monthlyReferenceAmount: recurringCharges.monthlyReferenceAmount,
        nextExpectedDate: recurringCharges.nextExpectedDate,
      ),
      recurringIncomes: AnalysisRecurringSummary(
        totalCount: recurringIncomes.plans.length,
        activeCount: recurringIncomes.activeCount,
        upcomingCount: recurringIncomes.upcomingCount,
        monthlyReferenceAmount: recurringIncomes.monthlyReferenceAmount,
        nextExpectedDate: recurringIncomes.nextExpectedDate,
      ),
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

import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/features/analysis/data/models/analysis_source_data.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_chart.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/analysis/domain/services/analysis_contact_categories.dart';
import 'package:bicount/features/analysis/domain/services/analysis_debt_balance_resolver.dart';
import 'package:bicount/features/analysis/domain/services/analysis_debt_transaction_classifier.dart';
import 'package:bicount/features/analysis/domain/services/analysis_time_series_builder.dart';
import 'package:bicount/features/analysis/domain/services/analysis_transaction_breakdown_matcher.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_collection_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';

part 'analysis_dashboard_calculation.dart';

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
    final transactions = source.transactions
        .where((row) => row.type != TransactionTypes.walletTransferCode)
        .toList();
    final filteredTransactions = timeSeriesBuilder.filterTransactions(
      transactions,
      period,
    );
    final currentUserParticipantIds = _resolveCurrentUserParticipantIds(source);
    final knownFriendParticipantIds = participantIdentityService
        .knownFriendParticipantIds(source.friends);
    final debtClassifier = AnalysisDebtTransactionClassifier(source.debts);
    final debtBalanceResolver = AnalysisDebtBalanceResolver(
      currentUserParticipantIds: currentUserParticipantIds,
      knownFriendParticipantIds: knownFriendParticipantIds,
      currencyAmountService: currencyAmountService,
    );
    final matcher = AnalysisTransactionBreakdownMatcher(
      debtClassifier: debtClassifier,
      currentUserParticipantIds: currentUserParticipantIds,
      knownFriendParticipantIds: knownFriendParticipantIds,
    );

    final income = _ordinaryBreakdown(
      filteredTransactions,
      currencyConfig,
      matcher.matchesGenericIncome,
      source,
      AnalysisChart.income,
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
    final expense = _ordinaryBreakdown(
      filteredTransactions,
      currencyConfig,
      matcher.matchesGenericExpense,
      source,
      AnalysisChart.expense,
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
        income.total +
        salaryAmount +
        debtIncomeAmount +
        debtRepaymentIncomeAmount +
        otherIncomeAmount;
    final outflow =
        expense.total +
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
      transactions: transactions,
      currencyConfig: currencyConfig,
      scope: RecurringPlanScope.charge,
    );
    final recurringIncomes = recurringPlanCollectionBuilder.build(
      recurringTransferts: source.recurringTransferts,
      transactions: transactions,
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
        knownFriendParticipantIds: knownFriendParticipantIds,
      ),
      incomeBreakdown: [
        AnalysisBreakdownItem(label: 'Income', value: income.general),
        AnalysisBreakdownItem(label: 'Salary', value: salaryAmount),
        AnalysisBreakdownItem(label: 'Debt', value: debtIncomeAmount),
        AnalysisBreakdownItem(
          label: 'Repayments',
          value: debtRepaymentIncomeAmount,
        ),
        AnalysisBreakdownItem(label: 'Other', value: otherIncomeAmount),
        ...income.contacts,
      ].where((item) => item.value > 0).toList(),
      expenseBreakdown: [
        AnalysisBreakdownItem(label: 'Expenses', value: expense.general),
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
        ...expense.contacts,
      ].where((item) => item.value > 0).toList(),
      recurringCharges: _recurringSummary(recurringCharges),
      recurringIncomes: _recurringSummary(recurringIncomes),
    );
  }
}

import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/services/graph_time_series_builder.dart';

class GraphDashboardBuilder {
  const GraphDashboardBuilder({
    this.timeSeriesBuilder = const GraphTimeSeriesBuilder(),
    this.currencyAmountService = const CurrencyAmountService(),
  });

  final GraphTimeSeriesBuilder timeSeriesBuilder;
  final CurrencyAmountService currencyAmountService;

  GraphDashboardEntity build(
    GraphSourceData source,
    GraphPeriod period,
    CurrencyConfigEntity currencyConfig,
  ) {
    final filteredTransactions = timeSeriesBuilder.filterTransactions(
      source.transactions,
      period,
    );

    final incomeAmount = filteredTransactions
        .where((t) => t.type == TransactionTypes.incomeCode)
        .fold<double>(
          0,
          (sum, t) =>
              sum + currencyAmountService.transaction(t, currencyConfig),
        );

    final salaryAmount = filteredTransactions
        .where((t) => t.type == TransactionTypes.salaryCode)
        .fold<double>(
          0,
          (sum, t) =>
              sum + currencyAmountService.transaction(t, currencyConfig),
        );

    final expenseAmount = filteredTransactions
        .where((t) => t.type == TransactionTypes.expenseCode)
        .fold<double>(
          0,
          (sum, t) =>
              sum + currencyAmountService.transaction(t, currencyConfig),
        );
    final subscriptionAmount = filteredTransactions
        .where((t) => t.type == TransactionTypes.subscriptionCode)
        .fold<double>(
          0,
          (sum, t) =>
              sum + currencyAmountService.transaction(t, currencyConfig),
        );
    final otherAmount = filteredTransactions
        .where((t) => t.type == TransactionTypes.othersCode)
        .fold<double>(
          0,
          (sum, t) =>
              sum + currencyAmountService.transaction(t, currencyConfig),
        );

    final inflow = incomeAmount + salaryAmount;
    final outflow = expenseAmount + subscriptionAmount + otherAmount;

    return GraphDashboardEntity(
      period: period,
      displayCurrencyCode: currencyConfig.referenceCurrencyCode,
      inflow: inflow,
      outflow: outflow,
      netFlow: inflow - outflow,
      cashflowPoints: timeSeriesBuilder.buildCashflowPoints(
        filteredTransactions,
        period,
      ),
      incomeBreakdown: [
        GraphBreakdownItem(label: 'Income', value: incomeAmount),
        GraphBreakdownItem(label: 'Salary', value: salaryAmount),
      ].where((item) => item.value > 0).toList(),
      expenseBreakdown: [
        GraphBreakdownItem(label: 'Expenses', value: expenseAmount),
        GraphBreakdownItem(label: 'Subscriptions', value: subscriptionAmount),
        GraphBreakdownItem(label: 'Other', value: otherAmount),
      ].where((item) => item.value > 0).toList(),
    );
  }
}

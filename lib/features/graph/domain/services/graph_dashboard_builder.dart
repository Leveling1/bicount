import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/domain/services/currency_amount_service.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/services/graph_time_series_builder.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';

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
    final filteredFundings = timeSeriesBuilder.filterFundings(
      source.fundings,
      period,
    );
    final activeSubscriptions = _activeSubscriptions(source.subscriptions);

    final incomeFromTransactions = filteredTransactions
        .where((transaction) => transaction.type == TransactionTypes.incomeCode)
        .fold<double>(
          0,
          (sum, transaction) =>
              sum +
              currencyAmountService.transaction(transaction, currencyConfig),
        );
    final addFundsAmount = filteredFundings.fold<double>(
      0,
      (sum, funding) =>
          sum + currencyAmountService.funding(funding, currencyConfig),
    );
    final expenseAmount = filteredTransactions
        .where(
          (transaction) => transaction.type == TransactionTypes.expenseCode,
        )
        .fold<double>(
          0,
          (sum, transaction) =>
              sum +
              currencyAmountService.transaction(transaction, currencyConfig),
        );
    final subscriptionAmount = filteredTransactions
        .where(
          (transaction) =>
              transaction.type == TransactionTypes.subscriptionCode,
        )
        .fold<double>(
          0,
          (sum, transaction) =>
              sum +
              currencyAmountService.transaction(transaction, currencyConfig),
        );
    final otherAmount = filteredTransactions
        .where((transaction) => transaction.type == TransactionTypes.othersCode)
        .fold<double>(
          0,
          (sum, transaction) =>
              sum +
              currencyAmountService.transaction(transaction, currencyConfig),
        );

    final inflow = incomeFromTransactions + addFundsAmount;
    final outflow = expenseAmount + subscriptionAmount + otherAmount;
    final dueSoonAmount = activeSubscriptions
        .where(
          (subscription) =>
              timeSeriesBuilder
                  .resolveSubscriptionDate(subscription.nextBillingDate)
                  .difference(timeSeriesBuilder.startOfDay(DateTime.now()))
                  .inDays <=
              7,
        )
        .fold<double>(
          0,
          (sum, subscription) =>
              sum +
              currencyAmountService.subscription(subscription, currencyConfig),
        );

    return GraphDashboardEntity(
      period: period,
      displayCurrencyCode: currencyConfig.referenceCurrencyCode,
      inflow: inflow,
      outflow: outflow,
      netFlow: inflow - outflow,
      activeSubscriptionCount: activeSubscriptions.length,
      monthlySubscriptionSpend: _estimateMonthlySubscriptionSpend(
        activeSubscriptions,
        currencyConfig,
      ),
      dueSoonAmount: dueSoonAmount,
      cashflowPoints: timeSeriesBuilder.buildCashflowPoints(
        filteredTransactions,
        filteredFundings,
        period,
      ),
      incomeBreakdown: [
        GraphBreakdownItem(label: 'AddFunds', value: addFundsAmount),
        GraphBreakdownItem(
          label: 'ReceivedTransfers',
          value: incomeFromTransactions,
        ),
      ].where((item) => item.value > 0).toList(),
      expenseBreakdown: [
        GraphBreakdownItem(label: 'Expenses', value: expenseAmount),
        GraphBreakdownItem(label: 'Subscriptions', value: subscriptionAmount),
        GraphBreakdownItem(label: 'Other', value: otherAmount),
      ].where((item) => item.value > 0).toList(),
      upcomingSubscriptions: activeSubscriptions.take(4).map((subscription) {
        return UpcomingSubscriptionEntity(
          subscriptionId: subscription.subscriptionId ?? subscription.sid,
          title: subscription.title,
          amount: subscription.amount,
          currency: subscription.currency,
          nextBillingDate: timeSeriesBuilder.resolveSubscriptionDate(
            subscription.nextBillingDate,
          ),
          frequency: subscription.frequency,
        );
      }).toList(),
    );
  }

  List<SubscriptionModel> _activeSubscriptions(
    List<SubscriptionModel> subscriptions,
  ) {
    final activeSubscriptions = subscriptions
        .where(
          (subscription) => SubscriptionConst.isActive(subscription.status),
        )
        .toList();

    activeSubscriptions.sort((left, right) {
      return timeSeriesBuilder
          .resolveSubscriptionDate(left.nextBillingDate)
          .compareTo(
            timeSeriesBuilder.resolveSubscriptionDate(right.nextBillingDate),
          );
    });
    return activeSubscriptions;
  }

  double _estimateMonthlySubscriptionSpend(
    List<SubscriptionModel> subscriptions,
    CurrencyConfigEntity currencyConfig,
  ) {
    return subscriptions.fold<double>(0, (sum, subscription) {
      return sum +
          currencyAmountService.monthlySubscription(
            subscription,
            currencyConfig,
          );
    });
  }
}

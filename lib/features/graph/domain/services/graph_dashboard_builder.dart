import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/services/graph_time_series_builder.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';

class GraphDashboardBuilder {
  const GraphDashboardBuilder({
    this.timeSeriesBuilder = const GraphTimeSeriesBuilder(),
  });

  final GraphTimeSeriesBuilder timeSeriesBuilder;

  GraphDashboardEntity build(GraphSourceData source, GraphPeriod period) {
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
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final addFundsAmount = filteredFundings.fold<double>(
      0,
      (sum, funding) => sum + funding.amount,
    );
    final expenseAmount = filteredTransactions
        .where(
          (transaction) => transaction.type == TransactionTypes.expenseCode,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final subscriptionAmount = filteredTransactions
        .where(
          (transaction) =>
              transaction.type == TransactionTypes.subscriptionCode,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final otherAmount = filteredTransactions
        .where((transaction) => transaction.type == TransactionTypes.othersCode)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

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
        .fold<double>(0, (sum, subscription) => sum + subscription.amount);

    return GraphDashboardEntity(
      period: period,
      inflow: inflow,
      outflow: outflow,
      netFlow: inflow - outflow,
      activeSubscriptionCount: activeSubscriptions.length,
      monthlySubscriptionSpend: _estimateMonthlySubscriptionSpend(
        activeSubscriptions,
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
          (subscription) =>
              (subscription.status ?? SubscriptionConst.active) ==
              SubscriptionConst.active,
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
  ) {
    return subscriptions.fold<double>(0, (sum, subscription) {
      switch (subscription.frequency) {
        case Frequency.weekly:
          return sum + (subscription.amount * 4.345);
        case Frequency.monthly:
          return sum + subscription.amount;
        case Frequency.quarterly:
          return sum + (subscription.amount / 3);
        case Frequency.yearly:
          return sum + (subscription.amount / 12);
        case Frequency.oneTime:
        default:
          return sum + subscription.amount;
      }
    });
  }
}

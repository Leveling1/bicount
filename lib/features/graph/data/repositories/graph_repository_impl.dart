import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/data/data_sources/local_datasource/graph_local_datasource.dart';
import 'package:bicount/features/graph/data/models/graph_source_data.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/graph/domain/repositories/graph_repository.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class GraphRepositoryImpl implements GraphRepository {
  GraphRepositoryImpl(this.localDataSource);

  final GraphLocalDataSource localDataSource;

  @override
  Stream<GraphDashboardEntity> watchDashboard(GraphPeriod period) {
    return Rx.combineLatest3(
      localDataSource.watchTransactions(),
      localDataSource.watchSubscriptions(),
      localDataSource.watchAccountFundings(),
      (
        List<TransactionModel> transactions,
        List<SubscriptionModel> subscriptions,
        List<AccountFundingModel> fundings,
      ) {
        return _buildDashboard(
          GraphSourceData(
            transactions: transactions,
            subscriptions: subscriptions,
            fundings: fundings,
          ),
          period,
        );
      },
    );
  }

  GraphDashboardEntity _buildDashboard(
    GraphSourceData source,
    GraphPeriod period,
  ) {
    final filteredTransactions = _filterTransactions(
      source.transactions,
      period,
    );
    final filteredFundings = _filterFundings(source.fundings, period);
    final activeSubscriptions =
        source.subscriptions
            .where(
              (subscription) =>
                  (subscription.status ?? SubscriptionConst.active) ==
                  SubscriptionConst.active,
            )
            .toList()
          ..sort(
            (left, right) => _resolveSubscriptionDate(
              left.nextBillingDate,
            ).compareTo(_resolveSubscriptionDate(right.nextBillingDate)),
          );

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
              _resolveSubscriptionDate(
                subscription.nextBillingDate,
              ).difference(_startOfDay(DateTime.now())).inDays <=
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
      cashflowPoints: _buildCashflowPoints(
        filteredTransactions,
        filteredFundings,
        period,
      ),
      expenseBreakdown: [
        GraphBreakdownItem(label: 'Expenses', value: expenseAmount),
        GraphBreakdownItem(label: 'Subscriptions', value: subscriptionAmount),
        GraphBreakdownItem(label: 'Other', value: otherAmount),
      ].where((item) => item.value > 0).toList(),
      upcomingSubscriptions: activeSubscriptions
          .take(4)
          .map(
            (subscription) => UpcomingSubscriptionEntity(
              subscriptionId: subscription.subscriptionId ?? subscription.sid,
              title: subscription.title,
              amount: subscription.amount,
              currency: subscription.currency,
              nextBillingDate: _resolveSubscriptionDate(
                subscription.nextBillingDate,
              ),
              frequency: subscription.frequency,
            ),
          )
          .toList(),
    );
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
    GraphPeriod period,
  ) {
    final start = _periodStart(
      period,
      values: transactions.map(_resolveTransactionDate).toList(),
    );
    return transactions.where((transaction) {
      final date = _resolveTransactionDate(transaction);
      return !date.isBefore(start);
    }).toList();
  }

  List<AccountFundingModel> _filterFundings(
    List<AccountFundingModel> fundings,
    GraphPeriod period,
  ) {
    final start = _periodStart(
      period,
      values: fundings.map(_resolveFundingDate).toList(),
    );
    return fundings.where((funding) {
      final date = _resolveFundingDate(funding);
      return !date.isBefore(start);
    }).toList();
  }

  DateTime _periodStart(GraphPeriod period, {required List<DateTime> values}) {
    final today = _startOfDay(DateTime.now());
    switch (period) {
      case GraphPeriod.week7:
        return today.subtract(const Duration(days: 6));
      case GraphPeriod.month30:
        return today.subtract(const Duration(days: 29));
      case GraphPeriod.quarter90:
        return today.subtract(const Duration(days: 89));
      case GraphPeriod.all:
        if (values.isEmpty) {
          return today.subtract(const Duration(days: 29));
        }
        values.sort();
        final firstDate = values.first;
        return DateTime(firstDate.year, firstDate.month, 1);
    }
  }

  List<GraphCashflowPoint> _buildCashflowPoints(
    List<TransactionModel> transactions,
    List<AccountFundingModel> fundings,
    GraphPeriod period,
  ) {
    final start = _periodStart(
      period,
      values: [
        ...transactions.map(_resolveTransactionDate),
        ...fundings.map(_resolveFundingDate),
      ],
    );
    final end = _startOfDay(DateTime.now());

    final points = <GraphCashflowPoint>[];
    var cursor = start;
    var runningNet = 0.0;

    while (!cursor.isAfter(end)) {
      final currentKey = _bucketKey(cursor, period);
      final inflow = _bucketInflowForDate(
        transactions,
        fundings,
        currentKey,
        period,
      );
      final outflow = _bucketOutflowForDate(transactions, currentKey, period);
      runningNet += inflow - outflow;

      points.add(
        GraphCashflowPoint(
          date: cursor,
          inflow: inflow,
          outflow: outflow,
          cumulativeNet: runningNet,
        ),
      );

      cursor = period == GraphPeriod.all
          ? DateTime(cursor.year, cursor.month + 1, 1)
          : cursor.add(const Duration(days: 1));
    }

    return points;
  }

  double _bucketInflowForDate(
    List<TransactionModel> transactions,
    List<AccountFundingModel> fundings,
    String bucketKey,
    GraphPeriod period,
  ) {
    final transactionIncome = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionTypes.incomeCode &&
              _bucketKey(_resolveTransactionDate(transaction), period) ==
                  bucketKey,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final fundingIncome = fundings
        .where(
          (funding) =>
              _bucketKey(_resolveFundingDate(funding), period) == bucketKey,
        )
        .fold<double>(0, (sum, funding) => sum + funding.amount);

    return transactionIncome + fundingIncome;
  }

  double _bucketOutflowForDate(
    List<TransactionModel> transactions,
    String bucketKey,
    GraphPeriod period,
  ) {
    return transactions
        .where(
          (transaction) =>
              transaction.type != TransactionTypes.incomeCode &&
              _bucketKey(_resolveTransactionDate(transaction), period) ==
                  bucketKey,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
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

  String _bucketKey(DateTime value, GraphPeriod period) {
    if (period == GraphPeriod.all) {
      return DateFormat('yyyy-MM').format(DateTime(value.year, value.month));
    }
    return DateFormat('yyyy-MM-dd').format(_startOfDay(value));
  }

  DateTime _resolveTransactionDate(TransactionModel transaction) {
    return _parseDate(transaction.date) ??
        _parseDate(transaction.createdAt) ??
        _startOfDay(DateTime.now());
  }

  DateTime _resolveFundingDate(AccountFundingModel funding) {
    return _parseDate(funding.date) ??
        _parseDate(funding.createdAt) ??
        _startOfDay(DateTime.now());
  }

  DateTime _resolveSubscriptionDate(String rawDate) {
    return _parseDate(rawDate) ?? _startOfDay(DateTime.now());
  }

  DateTime? _parseDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawDate)?.toLocal();
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

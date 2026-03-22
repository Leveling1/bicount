import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:intl/intl.dart';

class GraphTimeSeriesBuilder {
  const GraphTimeSeriesBuilder();

  List<TransactionModel> filterTransactions(
    List<TransactionModel> transactions,
    GraphPeriod period,
  ) {
    final start = periodStart(
      period,
      values: transactions.map(resolveTransactionDate).toList(),
    );
    return transactions.where((transaction) {
      final date = resolveTransactionDate(transaction);
      return !date.isBefore(start);
    }).toList();
  }

  List<AccountFundingModel> filterFundings(
    List<AccountFundingModel> fundings,
    GraphPeriod period,
  ) {
    final start = periodStart(
      period,
      values: fundings.map(resolveFundingDate).toList(),
    );
    return fundings.where((funding) {
      final date = resolveFundingDate(funding);
      return !date.isBefore(start);
    }).toList();
  }

  List<GraphCashflowPoint> buildCashflowPoints(
    List<TransactionModel> transactions,
    List<AccountFundingModel> fundings,
    GraphPeriod period,
  ) {
    final start = periodStart(
      period,
      values: [
        ...transactions.map(resolveTransactionDate),
        ...fundings.map(resolveFundingDate),
      ],
    );
    final end = startOfDay(DateTime.now());

    final points = <GraphCashflowPoint>[];
    var cursor = start;
    var runningNet = 0.0;

    while (!cursor.isAfter(end)) {
      final currentKey = bucketKey(cursor, period);
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

  DateTime periodStart(GraphPeriod period, {required List<DateTime> values}) {
    final today = startOfDay(DateTime.now());
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

  DateTime resolveTransactionDate(TransactionModel transaction) {
    return parseDate(transaction.date) ??
        parseDate(transaction.createdAt) ??
        startOfDay(DateTime.now());
  }

  DateTime resolveFundingDate(AccountFundingModel funding) {
    return parseDate(funding.date) ??
        parseDate(funding.createdAt) ??
        startOfDay(DateTime.now());
  }

  DateTime resolveSubscriptionDate(String rawDate) {
    return parseDate(rawDate) ?? startOfDay(DateTime.now());
  }

  DateTime startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime? parseDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDate)?.toLocal();
  }

  String bucketKey(DateTime value, GraphPeriod period) {
    if (period == GraphPeriod.all) {
      return DateFormat('yyyy-MM').format(DateTime(value.year, value.month));
    }
    return DateFormat('yyyy-MM-dd').format(startOfDay(value));
  }

  double _bucketInflowForDate(
    List<TransactionModel> transactions,
    List<AccountFundingModel> fundings,
    String bucketKeyValue,
    GraphPeriod period,
  ) {
    final transactionIncome = transactions
        .where(
          (transaction) =>
              transaction.type == TransactionTypes.incomeCode &&
              bucketKey(resolveTransactionDate(transaction), period) ==
                  bucketKeyValue,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final fundingIncome = fundings
        .where(
          (funding) =>
              bucketKey(resolveFundingDate(funding), period) == bucketKeyValue,
        )
        .fold<double>(0, (sum, funding) => sum + funding.amount);

    return transactionIncome + fundingIncome;
  }

  double _bucketOutflowForDate(
    List<TransactionModel> transactions,
    String bucketKeyValue,
    GraphPeriod period,
  ) {
    return transactions
        .where(
          (transaction) =>
              transaction.type != TransactionTypes.incomeCode &&
              bucketKey(resolveTransactionDate(transaction), period) ==
                  bucketKeyValue,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }
}

import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/graph/domain/entities/graph_dashboard_entity.dart';
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

  List<GraphCashflowPoint> buildCashflowPoints(
    List<TransactionModel> transactions,
    GraphPeriod period, {
    Set<String>? currentUserParticipantIds,
  }) {
    final start = periodStart(
      period,
      values: transactions.map(resolveTransactionDate).toList(),
    );
    final end = startOfDay(DateTime.now());

    final points = <GraphCashflowPoint>[];
    var cursor = start;
    var runningNet = 0.0;

    while (!cursor.isAfter(end)) {
      final currentKey = bucketKey(cursor, period);
      final inflow = _bucketInflowForDate(
        transactions,
        currentKey,
        period,
        currentUserParticipantIds: currentUserParticipantIds,
      );
      final outflow = _bucketOutflowForDate(
        transactions,
        currentKey,
        period,
        currentUserParticipantIds: currentUserParticipantIds,
      );
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
    String bucketKeyValue,
    GraphPeriod period, {
    Set<String>? currentUserParticipantIds,
  }) {
    return transactions
        .where(
          (t) =>
              _isInflowTransaction(
                t,
                currentUserParticipantIds: currentUserParticipantIds,
              ) &&
              bucketKey(resolveTransactionDate(t), period) == bucketKeyValue,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double _bucketOutflowForDate(
    List<TransactionModel> transactions,
    String bucketKeyValue,
    GraphPeriod period, {
    Set<String>? currentUserParticipantIds,
  }) {
    return transactions
        .where(
          (t) =>
              _isOutflowTransaction(
                t,
                currentUserParticipantIds: currentUserParticipantIds,
              ) &&
              bucketKey(resolveTransactionDate(t), period) == bucketKeyValue,
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  bool _isInflowTransaction(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.beneficiaryId);
    }

    return transaction.type == TransactionTypes.incomeCode ||
        transaction.type == TransactionTypes.salaryCode ||
        transaction.type == TransactionTypes.otherRecurringIncomeCode;
  }

  bool _isOutflowTransaction(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
  }) {
    if (currentUserParticipantIds != null) {
      return currentUserParticipantIds.contains(transaction.senderId);
    }

    return transaction.type == TransactionTypes.expenseCode ||
        transaction.type == TransactionTypes.subscriptionCode ||
        transaction.type == TransactionTypes.otherRecurringExpenseCode ||
        transaction.type == TransactionTypes.othersCode;
  }
}

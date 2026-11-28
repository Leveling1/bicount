import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/features/analysis/domain/entities/analysis_dashboard_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:intl/intl.dart';

class AnalysisTimeSeriesBuilder {
  const AnalysisTimeSeriesBuilder({
    this.identityService = const TransactionParticipantIdentityService(),
  });

  final TransactionParticipantIdentityService identityService;

  List<TransactionModel> filterTransactions(
    List<TransactionModel> transactions,
    AnalysisPeriod period,
  ) {
    final start = periodStart(
      period,
      values: period == AnalysisPeriod.all
          ? transactions.map(resolveTransactionDate).toList()
          : const [],
    );
    final range = period.resolveRange(DateTime.now());
    final end = range == null ? null : startOfDay(range.end);
    return transactions.where((transaction) {
      final day = startOfDay(resolveTransactionDate(transaction));
      return !day.isBefore(start) && (end == null || !day.isAfter(end));
    }).toList();
  }

  List<AnalysisCashflowPoint> buildCashflowPoints(
    List<TransactionModel> transactions,
    AnalysisPeriod period, {
    Set<String>? currentUserParticipantIds,
    Set<String> knownFriendParticipantIds = const {},
  }) {
    final start = periodStart(
      period,
      values: period == AnalysisPeriod.all
          ? transactions.map(resolveTransactionDate).toList()
          : const [],
    );
    final today = DateTime.now();
    final end = period.resolveRange(today)?.end ?? startOfDay(today);
    final transactionsByBucket = <String, List<TransactionModel>>{};
    for (final transaction in transactions) {
      final key = bucketKey(resolveTransactionDate(transaction), period);
      (transactionsByBucket[key] ??= []).add(transaction);
    }

    final points = <AnalysisCashflowPoint>[];
    var cursor = start;
    var runningNet = 0.0;

    while (!cursor.isAfter(end)) {
      final bucket =
          transactionsByBucket[bucketKey(cursor, period)] ?? const [];
      final inflow = _bucketInflowForDate(
        bucket,
        currentUserParticipantIds: currentUserParticipantIds,
        knownFriendParticipantIds: knownFriendParticipantIds,
      );
      final outflow = _bucketOutflowForDate(
        bucket,
        currentUserParticipantIds: currentUserParticipantIds,
        knownFriendParticipantIds: knownFriendParticipantIds,
      );
      runningNet += inflow - outflow;

      points.add(
        AnalysisCashflowPoint(
          date: cursor,
          inflow: inflow,
          outflow: outflow,
          cumulativeNet: runningNet,
        ),
      );

      cursor = period.usesMonthlyBuckets
          ? DateTime(cursor.year, cursor.month + 1, 1)
          : DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    return points;
  }

  DateTime periodStart(
    AnalysisPeriod period, {
    required List<DateTime> values,
  }) {
    final today = DateTime.now();
    final range = period.resolveRange(today);
    if (range != null) return range.start;
    if (values.isEmpty) {
      return DateTime(today.year, today.month, today.day - 29);
    }
    values.sort();
    final firstDate = values.first;
    return DateTime(firstDate.year, firstDate.month, 1);
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

  String bucketKey(DateTime value, AnalysisPeriod period) {
    if (period.usesMonthlyBuckets) {
      return DateFormat('yyyy-MM').format(DateTime(value.year, value.month));
    }
    return DateFormat('yyyy-MM-dd').format(startOfDay(value));
  }

  double _bucketInflowForDate(
    List<TransactionModel> transactions, {
    Set<String>? currentUserParticipantIds,
    Set<String> knownFriendParticipantIds = const {},
  }) {
    return transactions
        .where(
          (t) => _isInflowTransaction(
            t,
            currentUserParticipantIds: currentUserParticipantIds,
            knownFriendParticipantIds: knownFriendParticipantIds,
          ),
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double _bucketOutflowForDate(
    List<TransactionModel> transactions, {
    Set<String>? currentUserParticipantIds,
    Set<String> knownFriendParticipantIds = const {},
  }) {
    return transactions
        .where(
          (t) => _isOutflowTransaction(
            t,
            currentUserParticipantIds: currentUserParticipantIds,
            knownFriendParticipantIds: knownFriendParticipantIds,
          ),
        )
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  bool _isInflowTransaction(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
    Set<String> knownFriendParticipantIds = const {},
  }) {
    if (currentUserParticipantIds != null) {
      if (_isSelfMovement(transaction, currentUserParticipantIds)) {
        return TransactionTypes.isIncomeType(transaction.type);
      }
      return identityService.isMineWithFallback(
        candidateId: transaction.beneficiaryId,
        counterpartId: transaction.senderId,
        currentUserParticipantIds: currentUserParticipantIds,
        knownFriendParticipantIds: knownFriendParticipantIds,
      );
    }

    return transaction.type == TransactionTypes.incomeCode ||
        transaction.type == TransactionTypes.salaryCode ||
        transaction.type == TransactionTypes.otherRecurringIncomeCode;
  }

  bool _isOutflowTransaction(
    TransactionModel transaction, {
    Set<String>? currentUserParticipantIds,
    Set<String> knownFriendParticipantIds = const {},
  }) {
    if (currentUserParticipantIds != null) {
      if (_isSelfMovement(transaction, currentUserParticipantIds)) {
        return TransactionTypes.isExpenseType(transaction.type);
      }
      return identityService.isMineWithFallback(
        candidateId: transaction.senderId,
        counterpartId: transaction.beneficiaryId,
        currentUserParticipantIds: currentUserParticipantIds,
        knownFriendParticipantIds: knownFriendParticipantIds,
      );
    }

    return transaction.type == TransactionTypes.expenseCode ||
        transaction.type == TransactionTypes.subscriptionCode ||
        transaction.type == TransactionTypes.otherRecurringExpenseCode ||
        transaction.type == TransactionTypes.othersCode;
  }

  bool _isSelfMovement(
    TransactionModel transaction,
    Set<String> currentUserParticipantIds,
  ) =>
      currentUserParticipantIds.contains(transaction.senderId) &&
      currentUserParticipantIds.contains(transaction.beneficiaryId);
}

import 'dart:math' as math;

import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';

class TransactionSplitResolver {
  const TransactionSplitResolver();

  List<ResolvedTransactionSplitEntity> resolve(
    CreateTransactionRequestEntity request,
  ) {
    if (request.splits.isEmpty) {
      throw MessageFailure(message: 'Add at least one beneficiary.');
    }
    if (request.totalAmount <= 0) {
      throw MessageFailure(message: 'Enter an amount greater than zero.');
    }

    final totalCents = _toCents(request.totalAmount);
    switch (request.splitMode) {
      case TransactionSplitMode.equal:
        return _resolveEqual(request, totalCents);
      case TransactionSplitMode.percentage:
        return _resolvePercentage(request, totalCents);
      case TransactionSplitMode.customAmount:
        return _resolveCustomAmount(request, totalCents);
    }
  }

  List<ResolvedTransactionSplitEntity> _resolveEqual(
    CreateTransactionRequestEntity request,
    int totalCents,
  ) {
    final count = request.splits.length;
    final baseShare = totalCents ~/ count;
    final remainder = totalCents % count;
    final equalPercent = 100 / count;

    return request.splits.asMap().entries.map((entry) {
      final cents = baseShare + (entry.key < remainder ? 1 : 0);
      return ResolvedTransactionSplitEntity(
        beneficiary: entry.value.beneficiary,
        amount: _fromCents(cents),
        percentage: equalPercent,
      );
    }).toList();
  }

  List<ResolvedTransactionSplitEntity> _resolvePercentage(
    CreateTransactionRequestEntity request,
    int totalCents,
  ) {
    final percentages = request.splits.map((split) {
      final value = split.percentage;
      if (value == null || value.isNaN || value <= 0) {
        throw MessageFailure(
          message: 'Every beneficiary needs a percentage greater than zero.',
        );
      }
      return value;
    }).toList();

    final totalPercentage = percentages.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    if ((totalPercentage - 100).abs() > 0.01) {
      throw MessageFailure(message: 'Percentages must add up to 100%.');
    }

    final floorCents = <int>[];
    final remainders = <double>[];
    var allocated = 0;

    for (final percentage in percentages) {
      final rawCents = (totalCents * percentage) / 100;
      final floored = rawCents.floor();
      floorCents.add(floored);
      remainders.add(rawCents - floored);
      allocated += floored;
    }

    var leftover = totalCents - allocated;
    final indexedRemainders = remainders.asMap().entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    for (
      var index = 0;
      index < indexedRemainders.length && leftover > 0;
      index++
    ) {
      floorCents[indexedRemainders[index].key] += 1;
      leftover -= 1;
    }

    return request.splits.asMap().entries.map((entry) {
      return ResolvedTransactionSplitEntity(
        beneficiary: entry.value.beneficiary,
        amount: _fromCents(floorCents[entry.key]),
        percentage: percentages[entry.key],
      );
    }).toList();
  }

  List<ResolvedTransactionSplitEntity> _resolveCustomAmount(
    CreateTransactionRequestEntity request,
    int totalCents,
  ) {
    final amounts = request.splits.map((split) {
      final value = split.amount;
      if (value == null || value.isNaN || value <= 0) {
        throw MessageFailure(
          message: 'Every beneficiary needs an amount greater than zero.',
        );
      }
      return value;
    }).toList();

    final providedTotalCents = amounts.fold<int>(
      0,
      (sum, value) => sum + _toCents(value),
    );
    if (providedTotalCents != totalCents) {
      throw MessageFailure(
        message:
            'The split does not match the total amount. Check the individual amounts.',
      );
    }

    return request.splits.asMap().entries.map((entry) {
      final amount = amounts[entry.key];
      final percentage = request.totalAmount == 0
          ? 0.0
          : math.min<double>(100, (amount / request.totalAmount) * 100);
      return ResolvedTransactionSplitEntity(
        beneficiary: entry.value.beneficiary,
        amount: amount,
        percentage: percentage,
      );
    }).toList();
  }

  int _toCents(double amount) => (amount * 100).round();

  double _fromCents(int cents) => cents / 100;
}

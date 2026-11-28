import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class AnalysisPeriod extends Equatable {
  const AnalysisPeriod._(this.days, {this.isCurrentMonth = false})
    : dateRange = null;
  const AnalysisPeriod.custom(DateTimeRange range)
    : days = null,
      isCurrentMonth = false,
      dateRange = range;

  static const week7 = AnalysisPeriod._(7);
  static const month30 = AnalysisPeriod._(30);
  static const quarter90 = AnalysisPeriod._(90);
  static const currentMonth = AnalysisPeriod._(null, isCurrentMonth: true);
  static const all = AnalysisPeriod._(null);
  static const presets = [week7, month30, quarter90, currentMonth];

  final int? days;
  final DateTimeRange? dateRange;
  final bool isCurrentMonth;

  DateTimeRange? resolveRange(DateTime now) {
    final custom = dateRange;
    if (custom != null) {
      return DateTimeRange(
        start: DateUtils.dateOnly(custom.start),
        end: DateUtils.dateOnly(custom.end),
      );
    }
    if (isCurrentMonth) {
      return DateTimeRange(
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1, 0),
      );
    }
    final length = days;
    if (length == null) return null;
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day - length + 1),
      end: DateUtils.dateOnly(now),
    );
  }

  bool get usesMonthlyBuckets =>
      this == all || (dateRange?.duration.inDays ?? 0) >= 90;

  @override
  List<Object?> get props => [days, dateRange, isCurrentMonth];
}

extension AnalysisPeriodX on AnalysisPeriod {
  String label(BuildContext context) {
    if (isCurrentMonth) return context.l10n.analysisPeriodCurrentMonth;
    final range = dateRange;
    if (range != null) {
      final locale = Localizations.localeOf(context).toString();
      final end = DateFormat.yMMMd(locale).format(range.end);
      if (DateUtils.isSameDay(range.start, range.end)) return end;

      final startFormat = range.start.year == range.end.year
          ? DateFormat.MMMd(locale)
          : DateFormat.yMMMd(locale);
      return '${startFormat.format(range.start)} – $end';
    }
    return switch (days) {
      7 => context.l10n.analysisPeriod7DLabel,
      30 => context.l10n.analysisPeriod30DLabel,
      90 => context.l10n.analysisPeriod90DLabel,
      _ => context.l10n.analysisPeriodAllLabel,
    };
  }

  String description(BuildContext context) {
    if (isCurrentMonth || dateRange != null) return label(context);
    return switch (days) {
      7 => context.l10n.analysisPeriod7DDescription,
      30 => context.l10n.analysisPeriod30DDescription,
      90 => context.l10n.analysisPeriod90DDescription,
      _ => context.l10n.analysisPeriodAllDescription,
    };
  }
}

class AnalysisDashboardEntity extends Equatable {
  const AnalysisDashboardEntity({
    required this.period,
    required this.displayCurrencyCode,
    required this.inflow,
    required this.outflow,
    required this.netFlow,
    required this.receivableDebt,
    required this.payableDebt,
    required this.cashflowPoints,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.recurringCharges,
    required this.recurringIncomes,
  });

  final AnalysisPeriod period;
  final String displayCurrencyCode;
  final double inflow;
  final double outflow;
  final double netFlow;
  final double receivableDebt;
  final double payableDebt;
  final List<AnalysisCashflowPoint> cashflowPoints;
  final List<AnalysisBreakdownItem> incomeBreakdown;
  final List<AnalysisBreakdownItem> expenseBreakdown;
  final AnalysisRecurringSummary recurringCharges;
  final AnalysisRecurringSummary recurringIncomes;

  @override
  List<Object?> get props => [
    period,
    displayCurrencyCode,
    inflow,
    outflow,
    netFlow,
    receivableDebt,
    payableDebt,
    cashflowPoints,
    incomeBreakdown,
    expenseBreakdown,
    recurringCharges,
    recurringIncomes,
  ];
}

class AnalysisRecurringSummary extends Equatable {
  const AnalysisRecurringSummary({
    required this.totalCount,
    required this.activeCount,
    required this.upcomingCount,
    required this.monthlyReferenceAmount,
    required this.nextExpectedDate,
  });

  final int totalCount;
  final int activeCount;
  final int upcomingCount;
  final double monthlyReferenceAmount;
  final DateTime? nextExpectedDate;

  bool get hasPlans => totalCount > 0;

  @override
  List<Object?> get props => [
    totalCount,
    activeCount,
    upcomingCount,
    monthlyReferenceAmount,
    nextExpectedDate,
  ];
}

class AnalysisCashflowPoint extends Equatable {
  const AnalysisCashflowPoint({
    required this.date,
    required this.inflow,
    required this.outflow,
    required this.cumulativeNet,
  });

  final DateTime date;
  final double inflow;
  final double outflow;
  final double cumulativeNet;

  @override
  List<Object?> get props => [date, inflow, outflow, cumulativeNet];
}

class AnalysisBreakdownItem extends Equatable {
  const AnalysisBreakdownItem({
    required this.label,
    required this.value,
    this.friendSid,
  });

  final String label;
  final double value;
  final String? friendSid;

  @override
  List<Object?> get props => [label, value, friendSid];
}

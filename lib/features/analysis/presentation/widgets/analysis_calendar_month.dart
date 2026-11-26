import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class AnalysisCalendarMonth extends StatelessWidget {
  const AnalysisCalendarMonth({
    super.key,
    required this.month,
    required this.today,
    required this.firstDate,
    required this.lastDate,
    required this.start,
    required this.end,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime today;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final offset = DateUtils.firstDayOffset(month.year, month.month, material);
    final lastDay = DateUtils.getDaysInMonth(month.year, month.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Semantics(
            header: true,
            child: Text(
              material.formatMonthYear(month),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        for (
          var week = 0;
          week < offset + lastDay;
          week += DateTime.daysPerWeek
        )
          Row(
            children: [
              for (var column = 0; column < DateTime.daysPerWeek; column++)
                Expanded(child: _buildDay(week + column - offset + 1, lastDay)),
            ],
          ),
        AppDimens.spacerSmall,
      ],
    );
  }

  Widget _buildDay(int day, int lastDay) {
    if (day < 1 || day > lastDay) return const SizedBox(height: 44);

    final date = DateTime(month.year, month.month, day);
    final rangeStart = start;
    final rangeEnd = end;
    final isStart = DateUtils.isSameDay(date, rangeStart);
    final isEnd = DateUtils.isSameDay(date, rangeEnd);
    final inRange =
        rangeStart != null &&
        rangeEnd != null &&
        !DateUtils.isSameDay(rangeStart, rangeEnd) &&
        !date.isBefore(rangeStart) &&
        !date.isAfter(rangeEnd);
    return _CalendarDay(
      key: ValueKey(date),
      date: date,
      today: DateUtils.isSameDay(date, today),
      isStart: isStart,
      isEnd: isEnd,
      inRange: inRange,
      onTap: date.isBefore(firstDate) || date.isAfter(lastDate)
          ? null
          : () => onSelected(date),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    super.key,
    required this.date,
    required this.today,
    required this.isStart,
    required this.isEnd,
    required this.inRange,
    required this.onTap,
  });

  final DateTime date;
  final bool today;
  final bool isStart;
  final bool isEnd;
  final bool inRange;
  final VoidCallback? onTap;

  static const double _markerRadius = 19;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final terminal = isStart || isEnd;
    final material = MaterialLocalizations.of(context);
    final foreground = terminal
        ? (primary.computeLuminance() > 0.179 ? Colors.black : Colors.white)
        : onTap == null
        ? theme.disabledColor
        : null;

    return Semantics(
      label: material.formatFullDate(date),
      button: true,
      enabled: onTap != null,
      selected: terminal || inRange,
      onTap: onTap,
      excludeSemantics: true,
      child: SizedBox(
        height: 44,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (inRange)
              Align(
                alignment: isStart
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: terminal ? 0.5 : 1,
                  heightFactor: 1,
                  child: ColoredBox(color: primary.withValues(alpha: 0.10)),
                ),
              ),
            if (terminal || today)
              Center(
                child: SizedBox.square(
                  dimension: _markerRadius * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: terminal ? primary : null,
                      border: today && !terminal
                          ? Border.all(color: primary)
                          : null,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            Material(
              type: MaterialType.transparency,
              child: InkResponse(
                onTap: onTap,
                containedInkWell: true,
                customBorder: const CircleBorder(),
                radius: _markerRadius,
                splashFactory: NoSplash.splashFactory,
                child: Center(
                  child: Text(
                    material.formatDecimal(date.day),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

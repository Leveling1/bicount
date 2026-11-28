import 'package:flutter/material.dart';

class AnalysisMonthGrid extends StatelessWidget {
  const AnalysisMonthGrid({
    super.key,
    required this.month,
    required this.dayBuilder,
  });

  final DateTime month;
  final Widget Function(DateTime day) dayBuilder;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final offset = DateUtils.firstDayOffset(month.year, month.month, material);
    final lastDay = DateUtils.getDaysInMonth(month.year, month.month);

    return Column(
      children: [
        for (
          var week = 0;
          week < offset + lastDay;
          week += DateTime.daysPerWeek
        )
          Row(
            children: [
              for (var column = 0; column < DateTime.daysPerWeek; column++)
                Expanded(child: _cell(week + column - offset + 1, lastDay)),
            ],
          ),
      ],
    );
  }

  Widget _cell(int day, int lastDay) {
    if (day < 1 || day > lastDay) return const SizedBox.shrink();
    return dayBuilder(DateTime(month.year, month.month, day));
  }
}

class AnalysisMonthWeekdays extends StatelessWidget {
  const AnalysisMonthWeekdays({super.key});

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final style = Theme.of(context).textTheme.titleSmall;
    return Row(
      children: [
        for (var index = 0; index < DateTime.daysPerWeek; index++)
          Expanded(
            child: Center(
              child: Text(
                material.narrowWeekdays[(material.firstDayOfWeekIndex + index) %
                    DateTime.daysPerWeek],
                style: style,
              ),
            ),
          ),
      ],
    );
  }
}

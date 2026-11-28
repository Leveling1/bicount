import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_calendar_month.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_month_grid.dart';
import 'package:flutter/material.dart';

class AnalysisRangeCalendar extends StatefulWidget {
  const AnalysisRangeCalendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.initialRange,
    required this.onSaved,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange> onSaved;

  @override
  State<AnalysisRangeCalendar> createState() => _AnalysisRangeCalendarState();
}

class _AnalysisRangeCalendarState extends State<AnalysisRangeCalendar> {
  final _monthAnchor = GlobalKey();
  final _today = DateUtils.dateOnly(DateTime.now());
  late final _initialMonth = widget.initialRange?.start ?? _today;
  late DateTime? _start = widget.initialRange?.start;
  late DateTime? _end = widget.initialRange?.end;

  void _selectDay(DateTime day) {
    final start = _start;
    setState(() {
      if (start == null || _end != null || day.isBefore(start)) {
        _start = day;
        _end = null;
      } else {
        _end = day;
      }
    });
  }

  Widget _month(int offset) => AnalysisCalendarMonth(
    month: DateUtils.addMonthsToMonthDate(_initialMonth, offset),
    today: _today,
    firstDate: widget.firstDate,
    lastDate: widget.lastDate,
    start: _start,
    end: _end,
    onSelected: _selectDay,
  );

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final start = _start;
    final end = _end;
    final range = start == null || end == null
        ? null
        : DateTimeRange(start: start, end: end);
    final saveLabel = context.l10n.commonSave;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: range == null
                ? TextButton(onPressed: null, child: Text(saveLabel))
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.dp144,
                      maxHeight: AppSizes.dp44,
                    ),
                    child: CustomButton(
                      text: saveLabel,
                      loading: false,
                      onPressed: () => widget.onSaved(range),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingMedium,
            AppDimens.paddingSmall,
            AppDimens.paddingMedium,
            AppDimens.paddingLarge,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              switch ((start, end)) {
                (final start?, final end?) =>
                  '${material.formatShortDate(start)} – ${material.formatShortDate(end)}',
                (final start?, null) => material.formatShortDate(start),
                _ => material.dateRangePickerHelpText,
              },
              style: theme.textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const AnalysisMonthWeekdays(),
        const Divider(),
        Expanded(
          child: CustomScrollView(
            center: _monthAnchor,
            slivers: [
              SliverList.builder(
                itemCount: DateUtils.monthDelta(
                  widget.firstDate,
                  _initialMonth,
                ),
                itemBuilder: (_, index) => _month(-index - 1),
              ),
              SliverList.builder(
                key: _monthAnchor,
                itemCount:
                    DateUtils.monthDelta(_initialMonth, widget.lastDate) + 1,
                itemBuilder: (_, index) => _month(index),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

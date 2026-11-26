import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/other_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/analysis/domain/services/analysis_recurring_agenda.dart';
import 'package:bicount/features/analysis/presentation/widgets/analysis_month_grid.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'analysis_recurring_calendar_day.dart';

class AnalysisRecurringCalendar extends StatefulWidget {
  const AnalysisRecurringCalendar({
    super.key,
    required this.plans,
    this.monthFooterBuilder,
  });

  final List<RecurringTransfertModel> plans;
  final Widget Function(
    BuildContext,
    DateTime,
    Map<DateTime, List<AnalysisRecurringEntry>>,
  )?
  monthFooterBuilder;

  @override
  State<AnalysisRecurringCalendar> createState() =>
      _AnalysisRecurringCalendarState();
}

class _AnalysisRecurringCalendarState extends State<AnalysisRecurringCalendar> {
  static const _agenda = AnalysisRecurringAgenda();

  late final _today = DateUtils.dateOnly(DateTime.now());
  late DateTime _selectedDay = _today;
  late DateTime _month = DateTime(_today.year, _today.month);
  late var _entries = _agenda.forMonth(_month, widget.plans);

  @override
  void didUpdateWidget(covariant AnalysisRecurringCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.plans, widget.plans)) {
      _entries = _agenda.forMonth(_month, widget.plans);
    }
  }

  void _moveMonth(int offset) {
    setState(() {
      _month = DateUtils.addMonthsToMonthDate(_month, offset);
      _selectedDay = DateUtils.isSameMonth(_month, _today) ? _today : _month;
      _entries = _agenda.forMonth(_month, widget.plans);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final selectedEntries = _entries[_selectedDay] ?? const [];

    final calendar = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimens.spacingSmall,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
          ),
          child: Text(
            l10n.analysisRecurringCalendar,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _moveMonth(-1),
              tooltip: material.previousMonthTooltip,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                material.formatMonthYear(_month),
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () => _moveMonth(1),
              tooltip: material.nextMonthTooltip,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const AnalysisMonthWeekdays(),
        AnalysisMonthGrid(
          month: _month,
          dayBuilder: (date) => _AgendaDay(
            key: ValueKey(date),
            day: date,
            selected: date == _selectedDay,
            scopes: {
              for (final entry
                  in _entries[date] ?? const <AnalysisRecurringEntry>[])
                entry.scope,
            },
            onTap: () => setState(() => _selectedDay = date),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimens.spacingMedium,
          runSpacing: AppDimens.spacingExtraSmall,
          children: [
            for (final scope in [
              RecurringPlanScope.income,
              RecurringPlanScope.charge,
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimens.spacingExtraSmall,
                children: [
                  _AgendaMarker(scope),
                  Text(
                    scope.agendaLabel(context),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
        if (selectedEntries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppDimens.spacingSmall,
              children: [
                const Divider(),
                Text(
                  material.formatFullDate(_selectedDay),
                  style: theme.textTheme.titleSmall,
                ),
                for (final entry in selectedEntries) _AgendaEntry(entry),
              ],
            ),
          ),
      ],
    );
    final footerBuilder = widget.monthFooterBuilder;
    if (footerBuilder == null || _entries.isEmpty) return calendar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [calendar, footerBuilder(context, _month, _entries)],
    );
  }
}

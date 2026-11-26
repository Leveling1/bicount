import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/recurring_fundings/data/repositories/recurring_transfert_repository_impl.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_pause_action.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/repositories/recurring_transfert_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

Future<void> showRecurringPlanPauseSheet(
  BuildContext context, {
  required RecurringPlanPauseAction action,
  required List<RecurringPlanSummaryEntity> plans,
  bool bulk = false,
}) async {
  final saved = await showCustomBottomSheet<bool>(
    context: context,
    minHeight: 0.3,
    child: _RecurringPlanPauseSheet(
      action: action,
      plans: plans,
      bulk: bulk,
      repository: context.read<RecurringTransfertRepositoryImpl>(),
    ),
  );
  if (saved == true && context.mounted) {
    NotificationHelper.showSuccessNotification(
      context,
      action == RecurringPlanPauseAction.resume
          ? context.l10n.recurringPlanResumeSaved
          : context.l10n.recurringPlanPauseSaved,
    );
  }
}

class _RecurringPlanPauseSheet extends StatefulWidget {
  const _RecurringPlanPauseSheet({
    required this.action,
    required this.plans,
    required this.bulk,
    required this.repository,
  });

  final RecurringPlanPauseAction action;
  final List<RecurringPlanSummaryEntity> plans;
  final bool bulk;
  final RecurringTransfertRepository repository;

  @override
  State<_RecurringPlanPauseSheet> createState() =>
      _RecurringPlanPauseSheetState();
}

class _RecurringPlanPauseSheetState extends State<_RecurringPlanPauseSheet> {
  final _selected = <String, DateTime?>{};
  bool _saving = false;

  bool get _resuming => widget.action == RecurringPlanPauseAction.resume;

  @override
  void initState() {
    super.initState();
    if (!widget.bulk) {
      _selected[widget.plans.single.recurringTransfert.recurringTransfertId!] =
          null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = _resuming
        ? (widget.bulk
              ? l10n.recurringPlansResumeCta
              : l10n.recurringPlanResumeCta)
        : (widget.bulk
              ? l10n.recurringPlansPauseCta
              : l10n.recurringPlanPauseCta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        AppDimens.spacerSmall,
        Text(
          _resuming
              ? l10n.recurringPlanResumeNotice
              : l10n.recurringPlanPauseNotice,
        ),
        AppDimens.spacerMedium,
        for (final plan in widget.plans) _planRow(context, plan),
        AppDimens.spacerMedium,
        if (_selected.isEmpty)
          SizedBox(
            height: 50,
            child: ElevatedButton(onPressed: null, child: Text(title)),
          )
        else
          CustomButton(text: title, loading: _saving, onPressed: _save),
        AppDimens.spacerMedium,
      ],
    );
  }

  Widget _planRow(BuildContext context, RecurringPlanSummaryEntity summary) {
    final plan = summary.recurringTransfert;
    final id = plan.recurringTransfertId!;
    final override = _selected[id];
    final selected = _selected.containsKey(id);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.bulk)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: selected,
            title: Text(plan.title),
            onChanged: _saving
                ? null
                : (value) {
                    setState(() {
                      if (value == true) {
                        _selected[id] = null;
                      } else {
                        _selected.remove(id);
                      }
                    });
                  },
          )
        else
          Text(plan.title, style: Theme.of(context).textTheme.titleMedium),
        if (_resuming && selected) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              override == null ? Icons.check_circle : Icons.circle_outlined,
            ),
            title: Text(l10n.recurringPlanKeepSchedule),
            onTap: _saving ? null : () => setState(() => _selected[id] = null),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              override == null ? Icons.event_outlined : Icons.check_circle,
            ),
            title: Text(l10n.recurringPlanChooseResumeDate),
            subtitle: override == null
                ? null
                : Text(
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(override),
                  ),
            onTap: _saving ? null : () => _pickDate(id, plan.endDate),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate(String id, String? rawEndDate) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final lastDay =
        DateTime.tryParse(rawEndDate ?? '')?.toLocal() ??
        DateTime(today.year + 20, 12, 31);
    if (DateUtils.dateOnly(lastDay).isBefore(today)) return;
    final previous = _selected[id];
    final date = await showDatePicker(
      context: context,
      initialDate: previous == null || previous.isBefore(today)
          ? today
          : previous,
      firstDate: today,
      lastDate: lastDay,
    );
    if (date != null && mounted) setState(() => _selected[id] = date);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.repository.changePauses(
        ownerUid: widget.plans.first.recurringTransfert.uid,
        action: widget.action,
        changes: [
          for (final entry in _selected.entries)
            RecurringPlanPauseChange(entry.key, nextDueDate: entry.value),
        ],
      );
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      debugPrint('Saving recurring pauses failed: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.recurringPlanPauseError,
      );
    }
  }
}

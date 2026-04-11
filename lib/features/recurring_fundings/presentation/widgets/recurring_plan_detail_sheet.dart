import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_event.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_state.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_view.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showRecurringPlanDetailSheet(
  BuildContext context, {
  required RecurringPlanScope scope,
  required MainEntity data,
  required RecurringPlanSummaryEntity summary,
}) {
  return showCustomBottomSheet(
    context: context,
    minHeight: 0.65,
    color: null,
    child: RecurringPlanDetailSheet(scope: scope, data: data, summary: summary),
  );
}

class RecurringPlanDetailSheet extends StatefulWidget {
  const RecurringPlanDetailSheet({
    super.key,
    required this.scope,
    required this.data,
    required this.summary,
  });

  final RecurringPlanScope scope;
  final MainEntity data;
  final RecurringPlanSummaryEntity summary;

  @override
  State<RecurringPlanDetailSheet> createState() =>
      _RecurringPlanDetailSheetState();
}

class _RecurringPlanDetailSheetState extends State<RecurringPlanDetailSheet> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final targetId =
        widget.summary.recurringTransfert.recurringTransfertId ?? '';

    return BlocConsumer<RecurringTransfertBloc, RecurringTransfertState>(
      listener: (context, state) {
        if (state is RecurringTransfertActionSuccess &&
            state.targetId == targetId) {
          NotificationHelper.showSuccessNotification(
            context,
            _successMessage(context, state.message),
          );
          Navigator.of(context).maybePop();
          return;
        }

        if (state is RecurringTransfertActionFailure) {
          NotificationHelper.showFailureNotification(
            context,
            localizeRuntimeMessage(context, state.message),
          );
        }
      },
      builder: (context, state) {
        if (_isEditing) {
          return RecurringPlanForm(summary: widget.summary);
        }

        return RecurringPlanDetailView(
          scope: widget.scope,
          data: widget.data,
          summary: widget.summary,
          isLoading:
              state is RecurringTransfertActionInProgress &&
              state.targetId == targetId,
          onEditPressed: () => setState(() => _isEditing = true),
          onDeletePressed: () => _confirmDelete(context),
          onTerminatePressed: widget.summary.isActive
              ? () => context.read<RecurringTransfertBloc>().add(
                  TerminateRecurringPlanRequested(
                    widget.summary.recurringTransfert,
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: Theme.of(dialogContext).dialogTheme.shape,
        title: Text(context.l10n.recurringPlanDeleteConfirmTitle),
        content: Text(
          widget.scope == RecurringPlanScope.income
              ? context.l10n.recurringIncomeDeleteWarning
              : context.l10n.recurringChargeDeleteWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonReject),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.recurringPlanDeleteConfirmCta),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RecurringTransfertBloc>().add(
        DeleteRecurringPlanRequested(widget.summary.recurringTransfert),
      );
    }
  }

  String _successMessage(BuildContext context, String message) {
    return switch (message) {
      'Recurring plan updated.' => context.l10n.recurringPlanUpdatedSuccess,
      'Recurring plan stopped.' => context.l10n.recurringPlanStoppedSuccess,
      'Recurring plan deleted.' => context.l10n.recurringPlanDeletedSuccess,
      _ => message,
    };
  }
}

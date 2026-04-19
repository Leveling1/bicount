import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_scope.dart';
import 'package:bicount/features/recurring_fundings/domain/entities/recurring_plan_summary_entity.dart';
import 'package:bicount/features/recurring_fundings/domain/services/recurring_plan_collection_builder.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_event.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_state.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_skeleton.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_detail_view.dart';
import 'package:bicount/features/recurring_fundings/presentation/widgets/recurring_plan_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showRecurringPlanDetailSheet(
  BuildContext context, {
  required RecurringPlanScope scope,
  required String recurringTransfertId,
}) {
  return showCustomBottomSheet(
    context: context,
    minHeight: 0.65,
    color: null,
    child: BlocProvider.value(
      value: context.read<RecurringTransfertBloc>(),
      child: RecurringPlanDetailSheet(
        scope: scope,
        recurringTransfertId: recurringTransfertId,
      ),
    ),
  );
}

class RecurringPlanDetailSheet extends StatefulWidget {
  const RecurringPlanDetailSheet({
    super.key,
    required this.scope,
    required this.recurringTransfertId,
  });

  final RecurringPlanScope scope;
  final String recurringTransfertId;

  @override
  State<RecurringPlanDetailSheet> createState() =>
      _RecurringPlanDetailSheetState();
}

class _RecurringPlanDetailSheetState extends State<RecurringPlanDetailSheet> {
  static const RecurringPlanCollectionBuilder _collectionBuilder =
      RecurringPlanCollectionBuilder();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final currencyConfig = context.watch<CurrencyCubit>().state.config;
    final targetId = widget.recurringTransfertId;

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
      builder: (context, recurringState) {
        return BlocBuilder<MainBloc, MainState>(
          builder: (context, mainState) {
            if (mainState is MainLoaded) {
              final summary = _resolveSummary(
                data: mainState.startData,
                currencyConfig: currencyConfig,
              );
              if (summary == null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    widget.scope == RecurringPlanScope.income
                        ? context.l10n.recurringIncomesEmpty
                        : context.l10n.recurringChargesEmpty,
                  ),
                );
              }

              if (_isEditing) {
                return RecurringPlanForm(summary: summary);
              }

              return RecurringPlanDetailView(
                scope: widget.scope,
                data: mainState.startData,
                summary: summary,
                isLoading:
                    recurringState is RecurringTransfertActionInProgress &&
                    recurringState.targetId == targetId,
                onEditPressed: () => setState(() => _isEditing = true),
                onDeletePressed: () => _confirmDelete(context, summary),
                onTerminatePressed: summary.isActive
                    ? () => context.read<RecurringTransfertBloc>().add(
                        TerminateRecurringPlanRequested(
                          summary.recurringTransfert,
                        ),
                      )
                    : null,
              );
            }

            if (mainState is MainError) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FilledButton(
                  onPressed: () =>
                      context.read<MainBloc>().add(GetAllStartData()),
                  child: Text(context.l10n.commonRetry),
                ),
              );
            }

            return const RecurringPlanDetailSkeleton();
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RecurringPlanSummaryEntity summary,
  ) async {
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
        DeleteRecurringPlanRequested(summary.recurringTransfert),
      );
    }
  }

  RecurringPlanSummaryEntity? _resolveSummary({
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
  }) {
    final collection = _collectionBuilder.build(
      recurringTransferts: data.recurringTransferts,
      transactions: data.transactions,
      currencyConfig: currencyConfig,
      scope: widget.scope,
    );

    for (final summary in collection.plans) {
      if (summary.recurringTransfert.recurringTransfertId ==
          widget.recurringTransfertId) {
        return summary;
      }
    }

    return null;
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

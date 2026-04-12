import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_bloc.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_event.dart';
import 'package:bicount/features/recurring_fundings/presentation/bloc/recurring_transfert_state.dart';
import 'package:bicount/features/salary/domain/entities/salary_dashboard_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_occurrence_card.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_occurrence_sheet.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_overview_metrics.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringSalaryScreen extends StatefulWidget {
  const RecurringSalaryScreen({
    super.key,
    this.focusRecurringFundingId,
    this.focusExpectedDate,
  });

  final String? focusRecurringFundingId;
  final String? focusExpectedDate;

  @override
  State<RecurringSalaryScreen> createState() => _RecurringSalaryScreenState();
}

class _RecurringSalaryScreenState extends State<RecurringSalaryScreen> {
  static const SalaryDashboardBuilder _dashboardBuilder =
      SalaryDashboardBuilder();
  bool _hasOpenedFocusedOccurrence = false;

  @override
  Widget build(BuildContext context) {
    final currencyConfig = context.watch<CurrencyCubit>().state.config;

    return BlocConsumer<RecurringTransfertBloc, RecurringTransfertState>(
      listener: _onStateChanged,
      builder: (context, recurringState) {
        return BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(title: context.l10n.salaryTrackingTitle),
              body: switch (state) {
                MainLoaded() => _buildContent(
                  context,
                  _dashboardBuilder.build(
                    recurringTransferts: state.startData.recurringTransferts,
                    transactions: state.startData.transactions,
                    currencyConfig: currencyConfig,
                  ),
                  recurringState,
                  state.startData.referenceCurrencyCode,
                ),
                MainError() => _ErrorState(
                  onRetry: () =>
                      context.read<MainBloc>().add(GetAllStartData()),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    SalaryDashboardEntity dashboard,
    RecurringTransfertState recurringState,
    String referenceCurrencyCode,
  ) {
    _openFocusedOccurrenceIfNeeded(context, dashboard, recurringState);
    if (!dashboard.hasPlans) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLarge),
          child: Text(
            context.l10n.salaryEmptyState,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SalaryOverviewMetrics(
            dashboard: dashboard,
            currencyCode: referenceCurrencyCode,
          ),
          if (dashboard.attentionOccurrences.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingLarge),
            Text(
              context.l10n.salaryAttentionSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            ...dashboard.attentionOccurrences.map(
              (occurrence) => SalaryOccurrenceCard(
                occurrence: occurrence,
                onTap: () =>
                    _openOccurrenceSheet(context, occurrence, recurringState),
              ),
            ),
          ],
          const SizedBox(height: AppDimens.spacingLarge),
          Text(
            context.l10n.salaryPlansTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.spacingSmall),
          ...dashboard.plans.map(
            (plan) =>
                SalaryPlanCard(plan: plan, currencyCode: referenceCurrencyCode),
          ),
          if (dashboard.recentReceivedOccurrences.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingLarge),
            Text(
              context.l10n.salaryRecentPaymentsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            ...dashboard.recentReceivedOccurrences.map(
              (occurrence) => SalaryOccurrenceCard(occurrence: occurrence),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openOccurrenceSheet(
    BuildContext context,
    SalaryOccurrenceEntity occurrence,
    RecurringTransfertState recurringState,
  ) {
    final targetId = switch (recurringState) {
      RecurringTransfertActionInProgress(:final targetId) => targetId,
      _ => '',
    };

    return showCustomBottomSheet<void>(
      context: context,
      minHeight: 0.75,
      child: SalaryOccurrenceSheet(
        occurrence: occurrence,
        isLoading:
            targetId == occurrence.occurrenceId ||
            targetId == occurrence.recurringTransfert.recurringTransfertId,
        onConfirmPressed: (confirmedAmount, confirmedCurrency) {
          Navigator.of(context).maybePop();
          context.read<RecurringTransfertBloc>().add(
            ConfirmSalaryOccurrenceRequested(
              occurrence: occurrence,
              confirmedAmount: confirmedAmount,
              confirmedCurrency: confirmedCurrency,
            ),
          );
        },
        onAutomaticModePressed: (confirmedAmount, confirmedCurrency) {
          Navigator.of(context).maybePop();
          context.read<RecurringTransfertBloc>().add(
            ContinueSalaryAutomaticallyRequested(
              occurrence: occurrence,
              confirmedAmount: confirmedAmount,
              confirmedCurrency: confirmedCurrency,
            ),
          );
        },
      ),
    );
  }

  void _openFocusedOccurrenceIfNeeded(
    BuildContext context,
    SalaryDashboardEntity dashboard,
    RecurringTransfertState recurringState,
  ) {
    if (_hasOpenedFocusedOccurrence) {
      return;
    }

    final recurringFundingId = widget.focusRecurringFundingId;
    final expectedDate = widget.focusExpectedDate;
    if (recurringFundingId == null ||
        recurringFundingId.isEmpty ||
        expectedDate == null ||
        expectedDate.isEmpty ||
        (dashboard.attentionOccurrences.isEmpty &&
            dashboard.recentReceivedOccurrences.isEmpty)) {
      return;
    }

    final occurrences = [
      ...dashboard.attentionOccurrences,
      ...dashboard.recentReceivedOccurrences,
    ];
    final target = occurrences.firstWhere(
      (occurrence) =>
          occurrence.recurringTransfert.recurringTransfertId ==
              recurringFundingId &&
          occurrence.expectedDate.toIso8601String().startsWith(expectedDate),
      orElse: () => occurrences.first,
    );

    _hasOpenedFocusedOccurrence = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _openOccurrenceSheet(context, target, recurringState);
    });
  }

  void _onStateChanged(BuildContext context, RecurringTransfertState state) {
    if (state is RecurringTransfertActionSuccess) {
      final message = switch (state.message) {
        'Recurring salary confirmed.' =>
          context.l10n.salaryPaymentConfirmedSuccess,
        'Recurring salary switched to automatic mode.' =>
          context.l10n.salaryAutomaticModeEnabledSuccess,
        _ => state.message,
      };
      NotificationHelper.showSuccessNotification(context, message);
      return;
    }

    if (state is RecurringTransfertActionFailure) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.message),
      );
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onRetry,
        child: Text(context.l10n.commonRetry),
      ),
    );
  }
}

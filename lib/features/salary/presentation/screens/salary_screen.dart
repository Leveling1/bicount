import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/salary/domain/entities/salary_dashboard_entity.dart';
import 'package:bicount/features/salary/domain/entities/salary_occurrence_entity.dart';
import 'package:bicount/features/salary/domain/services/salary_dashboard_builder.dart';
import 'package:bicount/features/salary/presentation/bloc/salary_bloc.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_occurrence_card.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_occurrence_sheet.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_overview_metrics.dart';
import 'package:bicount/features/salary/presentation/widgets/salary_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({
    super.key,
    this.focusRecurringFundingId,
    this.focusExpectedDate,
  });

  final String? focusRecurringFundingId;
  final String? focusExpectedDate;

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final SalaryDashboardBuilder _dashboardBuilder =
      const SalaryDashboardBuilder();
  bool _hasOpenedFocusedOccurrence = false;

  @override
  Widget build(BuildContext context) {
    final currencyConfig = context.watch<CurrencyCubit>().state.config;

    return BlocConsumer<SalaryBloc, SalaryState>(
      listener: _onStateChanged,
      builder: (context, salaryState) {
        return BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(title: context.l10n.salaryTrackingTitle),
              body: switch (state) {
                MainLoaded() => _buildContent(
                  context,
                  _dashboardBuilder.build(
                    recurringFundings: state.startData.recurringFundings,
                    accountFundings: state.startData.accountFundings,
                    currencyConfig: currencyConfig,
                  ),
                  salaryState,
                  state.startData.referenceCurrencyCode,
                ),
                MainError() => _SalaryErrorState(
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
    SalaryState salaryState,
    String referenceCurrencyCode,
  ) {
    _openFocusedOccurrenceIfNeeded(context, dashboard, salaryState);

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
                    _openOccurrenceSheet(context, occurrence, salaryState),
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
    SalaryState salaryState,
  ) {
    final targetId = switch (salaryState) {
      SalaryActionInProgress(:final targetId) => targetId,
      _ => '',
    };

    return showCustomBottomSheet<void>(
      context: context,
      minHeight: 0.7,
      child: SalaryOccurrenceSheet(
        occurrence: occurrence,
        isLoading:
            targetId == occurrence.occurrenceId ||
            targetId == occurrence.recurringFunding.recurringFundingId,
        onConfirmPressed: () {
          Navigator.of(context).maybePop();
          context.read<SalaryBloc>().add(
            SalaryOccurrenceConfirmRequested(occurrence),
          );
        },
        onAutomaticModePressed: () {
          Navigator.of(context).maybePop();
          context.read<SalaryBloc>().add(
            SalaryAutomaticModeRequested(occurrence),
          );
        },
      ),
    );
  }

  void _openFocusedOccurrenceIfNeeded(
    BuildContext context,
    SalaryDashboardEntity dashboard,
    SalaryState salaryState,
  ) {
    if (_hasOpenedFocusedOccurrence) {
      return;
    }

    final recurringFundingId = widget.focusRecurringFundingId;
    final expectedDate = widget.focusExpectedDate;
    if (recurringFundingId == null ||
        recurringFundingId.isEmpty ||
        expectedDate == null ||
        expectedDate.isEmpty) {
      return;
    }
    if (dashboard.attentionOccurrences.isEmpty &&
        dashboard.recentReceivedOccurrences.isEmpty) {
      return;
    }

    final target = dashboard.attentionOccurrences.firstWhere(
      (occurrence) =>
          occurrence.recurringFunding.recurringFundingId ==
              recurringFundingId &&
          occurrence.expectedDate.toIso8601String().startsWith(expectedDate),
      orElse: () => dashboard.attentionOccurrences.isNotEmpty
          ? dashboard.attentionOccurrences.first
          : dashboard.recentReceivedOccurrences.first,
    );

    _hasOpenedFocusedOccurrence = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _openOccurrenceSheet(context, target, salaryState);
    });
  }

  void _onStateChanged(BuildContext context, SalaryState state) {
    if (state is SalaryActionSuccess) {
      final message = switch (state.message) {
        'salary_payment_confirmed_success' =>
          context.l10n.salaryPaymentConfirmedSuccess,
        'salary_automatic_mode_enabled_success' =>
          context.l10n.salaryAutomaticModeEnabledSuccess,
        _ => state.message,
      };
      NotificationHelper.showSuccessNotification(context, message);
      return;
    }

    if (state is SalaryActionFailure) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.message),
      );
    }
  }
}

class _SalaryErrorState extends StatelessWidget {
  const _SalaryErrorState({required this.onRetry});

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

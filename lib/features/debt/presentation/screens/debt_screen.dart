import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_app_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/debt/domain/entities/debt_dashboard_entity.dart';
import 'package:bicount/features/debt/domain/entities/debt_list_scope.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/services/debt_view_service.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_detail_sheet.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_summary_card.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/debt_bloc.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({
    super.key,
    this.initialScope = DebtListScope.all,
    this.focusDebtId,
  });

  final DebtListScope initialScope;
  final String? focusDebtId;

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  static const DebtViewService _viewService = DebtViewService();
  bool _hasOpenedFocusedDebt = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DebtBloc, DebtState>(
      listener: _onDebtStateChanged,
      builder: (context, debtState) {
        return BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: context.l10n.debtScreenTitle,
                leading: BackButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                      return;
                    }
                    context.go('/');
                  },
                ),
                automaticallyImplyLeading: false,
              ),
              body: switch (state) {
                MainLoaded() => _buildLoadedState(context, state, debtState),
                MainError() => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingLarge),
                    child: Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                _ => const _DebtLoadingState(),
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    MainLoaded state,
    DebtState debtState,
  ) {
    final dashboard = _viewService.build(
      currentUserId: state.startData.user.uid,
      currentUserName: state.startData.user.username,
      friends: state.startData.friends,
      debts: state.startData.debts,
    );
    _openFocusedDebtIfNeeded(context, dashboard, debtState);

    final visibleDebts = dashboard.visibleDebts(widget.initialScope);
    if (visibleDebts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingLarge),
          child: Text(
            context.l10n.debtEmptyState,
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
          if (widget.initialScope != DebtListScope.payable &&
              dashboard.receivableDebts.isNotEmpty) ...[
            Text(
              context.l10n.debtReceivableSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            ...dashboard.receivableDebts.map(
              (summary) => DebtSummaryCard(
                summary: summary,
                openLabel: context.l10n.debtStatusOpen,
                overdueLabel: context.l10n.debtStatusOverdue,
                onTap: () => _openDetailSheet(context, summary, debtState),
              ),
            ),
          ],
          if (widget.initialScope == DebtListScope.all &&
              dashboard.receivableDebts.isNotEmpty &&
              dashboard.payableDebts.isNotEmpty)
            const SizedBox(height: AppDimens.spacingMedium),
          if (widget.initialScope != DebtListScope.receivable &&
              dashboard.payableDebts.isNotEmpty) ...[
            Text(
              context.l10n.debtPayableSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.spacingSmall),
            ...dashboard.payableDebts.map(
              (summary) => DebtSummaryCard(
                summary: summary,
                openLabel: context.l10n.debtStatusOpen,
                overdueLabel: context.l10n.debtStatusOverdue,
                onTap: () => _openDetailSheet(context, summary, debtState),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openDetailSheet(
    BuildContext context,
    DebtSummaryEntity summary,
    DebtState debtState,
  ) {
    final targetId = switch (debtState) {
      DebtActionInProgress(:final targetId) => targetId,
      _ => '',
    };

    return showCustomBottomSheet<void>(
      context: context,
      minHeight: 0.7,
      child: DebtDetailSheet(
        summary: summary,
        titleText: summary.debt.title,
        counterpartyLabel: context.l10n.debtCounterpartyLabel,
        expectedLabel: context.l10n.debtExpectedLabel,
        repaidLabel: context.l10n.debtRepaidLabel,
        remainingLabel: context.l10n.debtRemainingLabel,
        dueDateLabel: context.l10n.debtDueDateLabel,
        amountFieldLabel: context.l10n.debtPaymentAmountLabel,
        amountFieldHint: context.l10n.debtPaymentAmountHint,
        recordPaymentLabel: context.l10n.debtRecordPaymentCta,
        permissionHint: context.l10n.debtPermissionHint,
        invalidAmountMessage: context.l10n.debtInvalidPaymentAmount,
        isLoading: targetId == summary.debt.debtId,
        onRecordPayment: (amount) {
          Navigator.of(context).maybePop();
          context.read<DebtBloc>().add(
            RecordDebtPaymentRequested(
              RecordDebtPaymentRequestEntity(
                debtId: summary.debt.debtId ?? '',
                amount: amount,
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFocusedDebtIfNeeded(
    BuildContext context,
    DebtDashboardEntity dashboard,
    DebtState debtState,
  ) {
    if (_hasOpenedFocusedDebt) {
      return;
    }

    final focusDebtId = widget.focusDebtId;
    if (focusDebtId == null || focusDebtId.isEmpty) {
      return;
    }

    final summary = dashboard.findById(focusDebtId);
    if (summary == null) {
      return;
    }

    _hasOpenedFocusedDebt = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _openDetailSheet(context, summary, debtState);
    });
  }

  void _onDebtStateChanged(BuildContext context, DebtState state) {
    if (state is DebtActionSuccess) {
      final message = switch (state.message) {
        'Debt payment recorded.' => context.l10n.debtPaymentRecordedSuccess,
        _ => state.message,
      };
      NotificationHelper.showSuccessNotification(context, message);
      return;
    }

    if (state is DebtActionFailure) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.message),
      );
    }
  }
}

class _DebtLoadingState extends StatelessWidget {
  const _DebtLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Column(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppDimens.spacingMedium),
            child: DetailsCard(isMargin: false, child: SizedBox(height: 96)),
          ),
        ),
      ),
    );
  }
}

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
import 'package:bicount/features/debt/presentation/widgets/debt_contract_form.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_detail_sheet.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_summary_card.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
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
    _openFocusedDebtIfNeeded(context, dashboard, debtState, state);

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
                onTap: () =>
                    _openDetailSheet(context, summary, debtState, state),
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
                onTap: () =>
                    _openDetailSheet(context, summary, debtState, state),
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
    MainLoaded state,
  ) {
    final targetId = switch (debtState) {
      DebtActionInProgress(:final targetId) => targetId,
      _ => '',
    };
    final principalTransaction = _findPrincipalTransaction(state, summary);

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
        onRecordPayment: (amount, currency) {
          Navigator.of(context).maybePop();
          context.read<DebtBloc>().add(
            RecordDebtPaymentRequested(
              RecordDebtPaymentRequestEntity(
                debtId: summary.debt.debtId ?? '',
                amount: amount,
                currency: currency,
              ),
            ),
          );
        },
        onEditPressed: summary.canManageContract && principalTransaction != null
            ? () {
                Navigator.of(context).maybePop();
                _openEditSheet(context, summary, principalTransaction);
              }
            : null,
        onDeletePressed: summary.canManageContract
            ? () => _confirmDeleteContract(context, summary.debt.debtId ?? '')
            : null,
      ),
    );
  }

  Future<void> _openEditSheet(
    BuildContext context,
    DebtSummaryEntity summary,
    TransactionEntity principalTransaction,
  ) {
    return showCustomBottomSheet<void>(
      context: context,
      minHeight: 0.85,
      child: BlocConsumer<DebtBloc, DebtState>(
        listenWhen: (previous, current) => current is DebtActionSuccess,
        listener: (context, state) {
          if (state is DebtActionSuccess &&
              state.targetId == summary.debt.debtId &&
              state.message == 'Debt contract updated.') {
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final isLoading =
              state is DebtActionInProgress &&
              state.targetId == summary.debt.debtId;
          return DebtContractForm(
            debt: summary.debt,
            principalTransaction: principalTransaction,
            counterpartyName: summary.counterpartyName,
            isLoading: isLoading,
            onSubmit: (request) {
              context.read<DebtBloc>().add(UpdateDebtRequested(request));
            },
            onCancel: () => Navigator.of(context).maybePop(),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteContract(
    BuildContext context,
    String debtId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: Theme.of(dialogContext).dialogTheme.shape,
        title: Text(context.l10n.debtDeleteConfirmTitle),
        content: Text(context.l10n.debtDeleteConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.debtDeleteConfirmCta),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).maybePop();
      context.read<DebtBloc>().add(DeleteDebtRequested(debtId));
    }
  }

  TransactionEntity? _findPrincipalTransaction(
    MainLoaded state,
    DebtSummaryEntity summary,
  ) {
    for (final transaction in state.startData.transactions) {
      if (transaction.tid == summary.debt.principalTransactionId) {
        return TransactionEntity.fromTransaction(transaction);
      }
    }

    return null;
  }

  void _openFocusedDebtIfNeeded(
    BuildContext context,
    DebtDashboardEntity dashboard,
    DebtState debtState,
    MainLoaded state,
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
      _openDetailSheet(context, summary, debtState, state);
    });
  }

  void _onDebtStateChanged(BuildContext context, DebtState state) {
    if (state is DebtActionSuccess) {
      final message = switch (state.message) {
        'Debt payment recorded.' => context.l10n.debtPaymentRecordedSuccess,
        'Debt contract updated.' => context.l10n.debtUpdatedSuccess,
        'Debt contract deleted.' => context.l10n.debtDeletedSuccess,
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

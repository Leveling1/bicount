import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/debt/domain/entities/debt_summary_entity.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_contract_form.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_detail_sheet.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/debt_bloc.dart';

Future<void> showDebtDetailSheet({
  required BuildContext context,
  required DebtSummaryEntity summary,
  required DebtState debtState,
  required MainLoaded state,
}) {
  final targetId = switch (debtState) {
    DebtActionInProgress(:final targetId) => targetId,
    _ => '',
  };
  final debtBloc = context.read<DebtBloc>();
  final principalTransaction = findDebtPrincipalTransaction(state, summary);

  return showCustomBottomSheet<void>(
    context: context,
    minHeight: 0.7,
    child: Builder(
      builder: (sheetContext) => DebtDetailSheet(
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
        onRecordPayment: (amount, currency) async {
          if (sheetContext.mounted) {
            await Navigator.of(sheetContext).maybePop();
          }
          if (!debtBloc.isClosed) {
            debtBloc.add(
              RecordDebtPaymentRequested(
                RecordDebtPaymentRequestEntity(
                  debtId: summary.debt.debtId ?? '',
                  amount: amount,
                  currency: currency,
                ),
              ),
            );
          }
        },
        onEditPressed: summary.canManageContract && principalTransaction != null
            ? () async {
                if (sheetContext.mounted) {
                  await Navigator.of(sheetContext).maybePop();
                }
                if (!context.mounted) {
                  return;
                }
                await _openDebtEditSheet(
                  context: context,
                  debtBloc: debtBloc,
                  summary: summary,
                  principalTransaction: principalTransaction,
                );
              }
            : null,
        onDeletePressed: summary.canManageContract
            ? () => _confirmDebtDelete(
                context: context,
                sheetContext: sheetContext,
                debtBloc: debtBloc,
                debtId: summary.debt.debtId ?? '',
              )
            : null,
      ),
    ),
  );
}

TransactionEntity? findDebtPrincipalTransaction(
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

void handleDebtStateChanged(BuildContext context, DebtState state) {
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

Future<void> _openDebtEditSheet({
  required BuildContext context,
  required DebtBloc debtBloc,
  required DebtSummaryEntity summary,
  required TransactionEntity principalTransaction,
}) {
  return showCustomBottomSheet<void>(
    context: context,
    minHeight: 0.85,
    child: BlocProvider.value(
      value: debtBloc,
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
    ),
  );
}

Future<void> _confirmDebtDelete({
  required BuildContext context,
  required BuildContext sheetContext,
  required DebtBloc debtBloc,
  required String debtId,
}) async {
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

  if (confirmed == true) {
    if (sheetContext.mounted) {
      await Navigator.of(sheetContext).maybePop();
    }
    if (!debtBloc.isClosed) {
      debtBloc.add(DeleteDebtRequested(debtId));
    }
  }
}

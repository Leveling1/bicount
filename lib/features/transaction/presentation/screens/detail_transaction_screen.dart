import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/data/repositories/debt_repository_impl.dart';
import 'package:bicount/features/debt/presentation/bloc/debt_bloc.dart';
import 'package:bicount/features/debt/presentation/widgets/debt_contract_form.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_content.dart';
import 'package:bicount/features/transaction/presentation/widgets/expense_form.dart';
import 'package:bicount/features/transaction/presentation/widgets/income_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/transaction_detail_args.dart';

class DetailTransactionScreen extends StatefulWidget {
  const DetailTransactionScreen({super.key, required this.transaction});

  final TransactionDetailArgs transaction;

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  bool _isEditing = false;

  DebtModel? get _principalDebt {
    for (final debt in widget.transaction.debts) {
      if (debt.principalTransactionId ==
          widget.transaction.transactionDetail.tid) {
        return debt;
      }
    }

    return null;
  }

  bool get _isDebtRepayment {
    final originId = widget.transaction.transactionDetail.originId;
    if (originId == null || originId.isEmpty) {
      return false;
    }

    for (final debt in widget.transaction.debts) {
      if (debt.debtId == originId &&
          debt.principalTransactionId !=
              widget.transaction.transactionDetail.tid) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final transactionDetail = widget.transaction.transactionDetail;
    final principalDebt = _principalDebt;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final canManage = transactionDetail.uid == uid;

    if (principalDebt != null) {
      final canManageDebt = principalDebt.createdBy == uid;
      return BlocProvider(
        create: (context) => DebtBloc(context.read<DebtRepositoryImpl>()),
        child: BlocConsumer<DebtBloc, DebtState>(
          listenWhen: (previous, current) =>
              current is DebtActionSuccess || current is DebtActionFailure,
          listener: _onDebtStateChanged,
          builder: (context, state) {
            final isLoading =
                state is DebtActionInProgress &&
                state.targetId == principalDebt.debtId;

            if (_isEditing) {
              return DebtContractForm(
                debt: principalDebt,
                principalTransaction: transactionDetail,
                counterpartyName: _resolveCounterpartyName(principalDebt),
                isLoading: isLoading,
                onSubmit: (request) {
                  context.read<DebtBloc>().add(UpdateDebtRequested(request));
                },
                onCancel: () => setState(() => _isEditing = false),
              );
            }

            return TransactionDetailContent(
              transaction: widget.transaction,
              canManage: canManageDebt,
              isLoading: isLoading,
              onDeletePressed: canManageDebt
                  ? () => _confirmDebtDelete(context, principalDebt)
                  : null,
              onEditPressed: canManageDebt
                  ? () => setState(() => _isEditing = true)
                  : null,
            );
          },
        ),
      );
    }

    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          current is TransactionDeleted ||
          (!_isEditing && current is TransactionError),
      listener: _onTransactionStateChanged,
      builder: (context, state) {
        if (_isEditing) {
          final editForm = TransactionTypes.isIncomeType(transactionDetail.type)
              ? IncomeForm(
                  user: widget.transaction.user,
                  friends: widget.transaction.friends,
                  initialTransaction: transactionDetail,
                  onCompleted: () => Navigator.of(context).maybePop(),
                )
              : ExpenseForm(
                  user: widget.transaction.user,
                  friends: widget.transaction.friends,
                  initialTransaction: transactionDetail,
                  onCompleted: () => Navigator.of(context).maybePop(),
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.l10n.transactionEditTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              AppDimens.spacerMedium,
              editForm,
            ],
          );
        }

        return TransactionDetailContent(
          transaction: widget.transaction,
          canManage: canManage,
          isLoading: state is TransactionLoading,
          onDeletePressed: canManage ? () => _confirmDelete(context) : null,
          onEditPressed: canManage && !_isDebtRepayment
              ? () => setState(() => _isEditing = true)
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
        title: Text(context.l10n.transactionDeleteConfirmTitle),
        content: Text(context.l10n.transactionDeleteConfirmDescription),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.commonReject),
                ),
              ),
              AppDimens.spacerWidthMedium,
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(context.l10n.transactionDeleteConfirmCta),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TransactionBloc>().add(
        DeleteTransactionEvent(widget.transaction.transactionDetail),
      );
    }
  }

  Future<void> _confirmDebtDelete(BuildContext context, DebtModel debt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: Theme.of(dialogContext).dialogTheme.shape,
        title: Text(context.l10n.debtDeleteConfirmTitle),
        content: Text(context.l10n.debtDeleteConfirmDescription),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.commonCancel),
                ),
              ),
              AppDimens.spacerWidthMedium,
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(context.l10n.debtDeleteConfirmCta),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<DebtBloc>().add(DeleteDebtRequested(debt.debtId ?? ''));
    }
  }

  void _onTransactionStateChanged(
    BuildContext context,
    TransactionState state,
  ) {
    if (state is TransactionDeleted) {
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(
          context,
          context.l10n.transactionDeletedSuccess,
        );
        Navigator.of(context).maybePop();
      });
      return;
    }

    if (state is TransactionError) {
      _runAfterFrame(() {
        NotificationHelper.showFailureNotification(
          context,
          localizeRuntimeMessage(context, state.failure.message),
        );
      });
    }
  }

  void _onDebtStateChanged(BuildContext context, DebtState state) {
    if (state is DebtActionSuccess) {
      final message = switch (state.message) {
        'Debt contract updated.' => context.l10n.debtUpdatedSuccess,
        'Debt contract deleted.' => context.l10n.debtDeletedSuccess,
        _ => state.message,
      };
      _runAfterFrame(() {
        NotificationHelper.showSuccessNotification(context, message);
        Navigator.of(context).maybePop();
      });
      return;
    }

    if (state is DebtActionFailure) {
      _runAfterFrame(() {
        NotificationHelper.showFailureNotification(
          context,
          localizeRuntimeMessage(context, state.message),
        );
      });
    }
  }

  String _resolveCounterpartyName(DebtModel debt) {
    final currentUserId = widget.transaction.user.uid;
    final currentUserName = widget.transaction.user.username;
    final partyId = debt.lenderId == currentUserId
        ? debt.borrowerId
        : debt.lenderId;
    if (partyId == currentUserId) {
      return currentUserName;
    }

    for (final friend in widget.transaction.friends) {
      if (friend.sid == partyId || friend.uid == partyId) {
        return friend.username;
      }
    }

    return partyId;
  }

  void _runAfterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      action();
    });
  }
}

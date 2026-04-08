import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_content.dart';
import 'package:bicount/features/transaction/presentation/widgets/expense_form.dart';
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

  @override
  Widget build(BuildContext context) {
    final transactionDetail = widget.transaction.transactionDetail;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final canManage =
        transactionDetail.type != TransactionTypes.subscriptionCode &&
        transactionDetail.uid == uid;

    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          current is TransactionDeleted ||
          (!_isEditing && current is TransactionError),
      listener: _onTransactionStateChanged,
      builder: (context, state) {
        if (_isEditing) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.l10n.transactionEditTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              AppDimens.spacerMedium,
              ExpenseForm(
                user: widget.transaction.user,
                friends: widget.transaction.friends,
                initialTransaction: transactionDetail,
                onCompleted: () => Navigator.of(context).maybePop(),
              ),
            ],
          );
        }

        return TransactionDetailContent(
          transaction: widget.transaction,
          canManage: canManage,
          isLoading: state is TransactionLoading,
          onDeletePressed: canManage ? () => _confirmDelete(context) : null,
          onEditPressed: canManage
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
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonReject),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.transactionDeleteConfirmCta),
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

  void _runAfterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      action();
    });
  }
}

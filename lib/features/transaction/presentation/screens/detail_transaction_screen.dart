import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_content.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form.dart';
import 'package:flutter/material.dart';
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
    final canEdit =
        transactionDetail.type != TransactionTypes.subscriptionCode &&
        (transactionDetail.sender == uid || transactionDetail.uid == uid);

    if (_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.transactionEditTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          AppDimens.spacerMedium,
          TransferForm(
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
      canEdit: canEdit,
      onEditPressed: canEdit ? () => setState(() => _isEditing = true) : null,
    );
  }
}

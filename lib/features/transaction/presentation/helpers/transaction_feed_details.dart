import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_detail_args.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
import 'package:bicount/features/transaction/presentation/screens/detail_transaction_screen.dart';
import 'package:flutter/material.dart';

void showTransactionFeedDetails(
  BuildContext context, {
  required MainEntity data,
  required TransactionFeedItem item,
}) {
  showCustomBottomSheet(
    context: context,
    minHeight: 0.95,
    color: null,
    child: DetailTransactionScreen(
      transaction: TransactionDetailArgs(
        user: data.user,
        transactionDetail: item.transaction,
        friends: data.friends,
      ),
    ),
  );
}

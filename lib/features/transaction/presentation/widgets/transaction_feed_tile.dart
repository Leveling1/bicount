import 'package:bicount/core/widgets/transaction_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_details.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
import 'package:flutter/material.dart';

class TransactionFeedTile extends StatelessWidget {
  const TransactionFeedTile({
    super.key,
    required this.item,
    required this.data,
  });

  final TransactionFeedItem item;
  final MainEntity data;

  @override
  Widget build(BuildContext context) {
    return TransactionCard(
      transaction: item.transaction,
      onTap: () => showTransactionFeedDetails(context, data: data, item: item),
    );
  }
}

import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

class TransactionFeedItem {
  const TransactionFeedItem({
    required this.id,
    required this.timelineDate,
    required this.searchText,
    required this.filterType,
    required this.category,
    required this.transaction,
  });

  final String id;
  final DateTime timelineDate;
  final String searchText;
  final int filterType;
  final int? category;
  final TransactionEntity transaction;

  factory TransactionFeedItem.fromTransaction(TransactionModel transaction) {
    final timelineDate =
        DateTime.tryParse(transaction.createdAt ?? '') ??
        DateTime.tryParse(transaction.date) ??
        DateTime.now();

    return TransactionFeedItem(
      id: transaction.tid ?? transaction.gtid,
      timelineDate: timelineDate,
      searchText: '${transaction.name} ${transaction.note}'.toLowerCase(),
      filterType: transaction.type,
      category: transaction.category,
      transaction: TransactionEntity.fromTransaction(transaction),
    );
  }
}

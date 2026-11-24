import 'package:bicount/core/services/transaction_direction_service.dart';
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
    this.displayTitle,
    this.walletTransferDirection,
  });

  final String id;
  final DateTime timelineDate;
  final String searchText;
  final int filterType;
  final int? category;
  final TransactionEntity transaction;
  final String? displayTitle;
  final TransactionDirection? walletTransferDirection;

  factory TransactionFeedItem.fromTransaction(
    TransactionModel transaction, {
    String? displayTitle,
  }) {
    final timelineDate = DateTime.tryParse(transaction.date) ?? DateTime.now();

    return TransactionFeedItem(
      id: transaction.tid ?? transaction.gtid,
      timelineDate: timelineDate,
      searchText: [
        ?displayTitle,
        transaction.name,
        transaction.note,
      ].join(' ').toLowerCase(),
      filterType: transaction.type,
      category: transaction.category,
      transaction: TransactionEntity.fromTransaction(transaction),
      displayTitle: displayTitle,
    );
  }

  TransactionFeedItem withWalletTransferDirection(
    TransactionDirection direction,
  ) => TransactionFeedItem(
    id: id,
    timelineDate: timelineDate,
    searchText: searchText,
    filterType: filterType,
    category: category,
    transaction: transaction,
    displayTitle: displayTitle,
    walletTransferDirection: direction,
  );
}

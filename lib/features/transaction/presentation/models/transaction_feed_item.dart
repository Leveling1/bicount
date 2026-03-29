import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

enum TransactionFeedKind { transaction, addFund }

class TransactionFeedItem {
  const TransactionFeedItem({
    required this.id,
    required this.kind,
    required this.timelineDate,
    required this.searchText,
    required this.filterType,
    required this.category,
    this.transaction,
    this.accountFunding,
  });

  final String id;
  final TransactionFeedKind kind;
  final DateTime timelineDate;
  final String searchText;
  final int filterType;
  final int? category;
  final TransactionEntity? transaction;
  final AccountFundingModel? accountFunding;

  bool get isAddFund => kind == TransactionFeedKind.addFund;

  factory TransactionFeedItem.fromTransaction(TransactionModel transaction) {
    final timelineDate =
        DateTime.tryParse(transaction.createdAt ?? '') ??
        DateTime.tryParse(transaction.date) ??
        DateTime.now();

    return TransactionFeedItem(
      id: transaction.tid ?? transaction.gtid,
      kind: TransactionFeedKind.transaction,
      timelineDate: timelineDate,
      searchText: '${transaction.name} ${transaction.note}'.toLowerCase(),
      filterType: transaction.type,
      category: transaction.category,
      transaction: TransactionEntity.fromTransaction(transaction),
    );
  }

  factory TransactionFeedItem.fromAccountFunding(AccountFundingModel funding) {
    final timelineDate =
        DateTime.tryParse(funding.createdAt ?? '') ??
        DateTime.tryParse(funding.date) ??
        DateTime.now();

    return TransactionFeedItem(
      id: funding.fundingId,
      kind: TransactionFeedKind.addFund,
      timelineDate: timelineDate,
      searchText: '${funding.source} ${funding.note ?? ''}'.toLowerCase(),
      filterType: TransactionTypes.incomeCode,
      category: funding.category,
      accountFunding: funding,
    );
  }
}

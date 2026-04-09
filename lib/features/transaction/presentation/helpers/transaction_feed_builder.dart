import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
import 'package:flutter/material.dart';

List<TransactionFeedItem> buildTransactionFeed(MainEntity data) {
  final items = data.transactions
      .map(TransactionFeedItem.fromTransaction)
      .toList();

  items.sort((left, right) => right.timelineDate.compareTo(left.timelineDate));
  return items;
}

List<TransactionFeedItem> filterTransactionFeed({
  required List<TransactionFeedItem> source,
  required String query,
  required int selectedIndex,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final selectedCode = TransactionTypes.allTypesInt[selectedIndex];

  return source.where((item) {
    final matchesSearch =
        normalizedQuery.isEmpty || item.searchText.contains(normalizedQuery);
    if (!matchesSearch) {
      return false;
    }

    if (selectedIndex == 0) {
      return true;
    }

    return item.filterType == selectedCode;
  }).toList();
}

Map<String, List<TransactionFeedItem>> groupTransactionFeedByDate(
  BuildContext context,
  List<TransactionFeedItem> items,
) {
  final grouped = <String, List<TransactionFeedItem>>{};

  for (final item in items) {
    final key = context.transactionDateGroupLabel(item.timelineDate);
    grouped.putIfAbsent(key, () => []).add(item);
  }

  return grouped;
}

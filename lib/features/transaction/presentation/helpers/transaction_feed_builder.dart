import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
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
  required MainEntity data,
  required List<TransactionFeedItem> source,
  required String query,
  required int selectedIndex,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final currentUserParticipantIds =
      const TransactionParticipantIdentityService().currentUserParticipantIds(
        currentUserId: data.user.uid,
        friends: data.friends,
      );

  return source.where((item) {
    final matchesSearch =
        normalizedQuery.isEmpty || item.searchText.contains(normalizedQuery);
    if (!matchesSearch) {
      return false;
    }

    if (selectedIndex == 0) {
      return true;
    }

    return switch (selectedIndex) {
      1 => currentUserParticipantIds.contains(item.transaction.beneficiary),
      2 => currentUserParticipantIds.contains(item.transaction.sender),
      3 => item.filterType == TransactionTypes.subscriptionCode,
      4 => item.filterType == TransactionTypes.salaryCode,
      5 =>
        item.filterType == TransactionTypes.otherRecurringExpenseCode ||
            item.filterType == TransactionTypes.otherRecurringIncomeCode,
      _ => true,
    };
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

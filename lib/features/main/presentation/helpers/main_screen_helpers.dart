import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:flutter/material.dart';

List<String> localizedMainShellTitles(BuildContext context) {
  return [
    '',
    context.l10n.navGraphs,
    context.l10n.navTransaction,
    context.l10n.navProfile,
  ];
}

MainEntity prepareMainScreenData(MainEntity data) {
  final sortedTransactions = List.of(data.transactions);
  if (sortedTransactions.length > 1) {
    sortedTransactions.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  return MainEntity(
    user: data.user,
    connectionState: data.connectionState,
    referenceCurrencyCode: data.referenceCurrencyCode,
    friends: data.friends,
    transactions: sortedTransactions,
    recurringTransferts: data.recurringTransferts,
  );
}

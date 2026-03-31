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
  final sortedAccountFundings = List.of(data.accountFundings);
  if (sortedTransactions.length > 1) {
    sortedTransactions.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }
  if (sortedAccountFundings.length > 1) {
    sortedAccountFundings.sort(
      (a, b) => (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date),
    );
  }

  return MainEntity(
    user: data.user,
    connectionState: data.connectionState,
    referenceCurrencyCode: data.referenceCurrencyCode,
    monthlySubscriptionSpend: data.monthlySubscriptionSpend,
    friends: data.friends,
    subscriptions: data.subscriptions,
    transactions: sortedTransactions,
    accountFundings: sortedAccountFundings,
    recurringFundings: data.recurringFundings,
  );
}

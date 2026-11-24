import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/transaction_direction_service.dart';
import 'package:bicount/core/services/transaction_participant_identity_service.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/services/wallet_attribution.dart';
import 'package:flutter/material.dart';

List<TransactionFeedItem> buildTransactionFeed(
  MainEntity data, {
  BuildContext? context,
  List<WalletModel> wallets = const [],
}) {
  final walletsById = {for (final wallet in wallets) wallet.id: wallet};
  final items = data.transactions
      .map(
        (transaction) => TransactionFeedItem.fromTransaction(
          transaction,
          displayTitle: context == null
              ? null
              : _legacyTransferTitle(context, transaction, walletsById),
        ),
      )
      .toList();

  items.sort((left, right) => right.timelineDate.compareTo(left.timelineDate));
  return items;
}

const _legacyTransferTitles = {
  'Transfer between wallets',
  'Transférer entre portefeuilles',
};

String? _legacyTransferTitle(
  BuildContext context,
  TransactionModel transaction,
  Map<String, WalletModel> walletsById,
) {
  if (transaction.type != TransactionTypes.walletTransferCode ||
      !_legacyTransferTitles.contains(transaction.name)) {
    return null;
  }
  final principalId = WalletModel.principalId(transaction.uid);
  final from = walletsById[transaction.senderWalletId ?? principalId];
  final to = walletsById[transaction.beneficiaryWalletId ?? principalId];
  if (from == null || to == null || from.id == to.id) {
    return context.l10n.walletTransfer;
  }
  return context.l10n.walletTransferTitle(
    walletLabel(context, from),
    walletLabel(context, to),
  );
}

List<TransactionFeedItem> filterTransactionFeed({
  required MainEntity data,
  required List<TransactionFeedItem> source,
  required String query,
  required int selectedIndex,
  String? walletId,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final currentUserParticipantIds =
      const TransactionParticipantIdentityService().currentUserParticipantIds(
        currentUserId: data.user.uid,
        friends: data.friends,
      );

  final filtered = <TransactionFeedItem>[];
  for (final item in source) {
    if (!item.searchText.contains(normalizedQuery)) continue;
    final sides = walletId == null
        ? const <({bool sender, String id})>[]
        : walletSides(
            data,
            item.transaction,
          ).where((side) => side.id == walletId);
    if (walletId != null && sides.isEmpty) continue;

    if (item.filterType == TransactionTypes.walletTransferCode) {
      final sends = sides.any((side) => side.sender);
      final receives = sides.any((side) => !side.sender);
      final sign = sends == receives
          ? TransactionSign.none
          : sends
          ? TransactionSign.negative
          : TransactionSign.positive;
      final matchesType = switch (selectedIndex) {
        0 => true,
        1 => sign == TransactionSign.positive,
        2 => sign == TransactionSign.negative,
        _ => false,
      };
      if (matchesType) {
        filtered.add(
          item.withWalletTransferDirection(
            TransactionDirection(
              sign: sign,
              origin: TransactionOrigin.internal,
            ),
          ),
        );
      }
      continue;
    }

    if (selectedIndex == 0) {
      filtered.add(item);
      continue;
    }

    final isSender = currentUserParticipantIds.contains(
      item.transaction.sender,
    );
    final isBeneficiary = currentUserParticipantIds.contains(
      item.transaction.beneficiary,
    );
    final isSelfTransfer = isSender && isBeneficiary;
    final matchesType = switch (selectedIndex) {
      1 =>
        isBeneficiary &&
            (!isSelfTransfer || TransactionTypes.isIncomeType(item.filterType)),
      2 =>
        isSender &&
            (!isSelfTransfer ||
                TransactionTypes.isExpenseType(item.filterType)),
      3 => item.filterType == TransactionTypes.subscriptionCode,
      4 => item.filterType == TransactionTypes.salaryCode,
      5 => item.filterType == TransactionTypes.debtCode,
      6 =>
        item.filterType == TransactionTypes.otherRecurringExpenseCode ||
            item.filterType == TransactionTypes.otherRecurringIncomeCode,
      _ => true,
    };
    if (matchesType) filtered.add(item);
  }
  return filtered;
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

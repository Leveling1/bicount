import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_feed_tile.dart';
import 'package:bicount/features/wallet/domain/services/wallet_attribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletHistory extends StatelessWidget {
  const WalletHistory({super.key, required this.walletId});
  final String walletId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MainBloc>().state;
    if (state is! MainLoaded) return const SizedBox.shrink();
    final data = state.startData;
    final items = buildTransactionFeed(data)
        .where(
          (item) => walletSides(
            data,
            item.transaction,
          ).any((side) => side.id == walletId),
        )
        .toList();
    if (items.isEmpty)
      return Center(child: Text(context.l10n.walletNoMovements));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, index) =>
          TransactionFeedTile(item: items[index], data: data),
    );
  }
}

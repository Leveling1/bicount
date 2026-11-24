import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/domain/services/wallet_attribution.dart';
import 'transaction_wallet_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionWalletDetails extends StatefulWidget {
  const TransactionWalletDetails({super.key, required this.transaction});
  final TransactionEntity transaction;

  @override
  State<TransactionWalletDetails> createState() =>
      _TransactionWalletDetailsState();
}

class _TransactionWalletDetailsState extends State<TransactionWalletDetails> {
  late final _repository = WalletRepositoryImpl();
  late final _wallets = _repository.watch();

  @override
  Widget build(BuildContext context) {
    if (!BackendEnvironment.isLocalPreproduction) {
      return const SizedBox.shrink();
    }
    final state = context.watch<MainBloc>().state;
    if (state is! MainLoaded) return const SizedBox.shrink();
    final data = state.startData;
    final transaction = widget.transaction;
    final live = data.transactions
        .where((row) => row.tid == transaction.tid)
        .firstOrNull;
    final current = live == null
        ? transaction
        : TransactionEntity.fromTransaction(live);
    final sides = walletSides(data, current);
    if (sides.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<WalletModel>>(
      stream: _wallets,
      builder: (context, snapshot) {
        final wallets = snapshot.data ?? const [];
        final options = wallets
            .where((wallet) => wallet.archivedAt == null)
            .toList();
        final canChange =
            options.length > 1 &&
            current.type != TransactionTypes.walletTransferCode;

        return Column(
          children: [
            for (final side in sides)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionWalletDetailRow(
                  title: sides.length == 1
                      ? context.l10n.walletPicker
                      : side.sender
                      ? context.l10n.walletFrom
                      : context.l10n.walletTo,
                  wallet: wallets
                      .where((wallet) => wallet.id == side.id)
                      .firstOrNull,
                  options: options,
                  onChanged: canChange
                      ? (id) => _reassign(current.tid, side.sender, id)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _reassign(String tid, bool sender, String id) async {
    try {
      await _repository.assignTransaction(
        tid: tid,
        isSender: sender,
        walletId: id,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.walletError)));
      }
    }
  }
}

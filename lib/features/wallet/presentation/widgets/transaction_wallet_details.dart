import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/wallet/domain/services/wallet_attribution.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionWalletDetails extends StatelessWidget {
  const TransactionWalletDetails({super.key, required this.transaction});
  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    if (!BackendEnvironment.isLocalPreproduction)
      return const SizedBox.shrink();
    final state = context.watch<MainBloc>().state;
    if (state is! MainLoaded) return const SizedBox.shrink();
    final data = state.startData;
    final live = data.transactions
        .where((row) => row.tid == transaction.tid)
        .firstOrNull;
    final current = live == null
        ? transaction
        : TransactionEntity.fromTransaction(live);
    return Column(
      children: [
        for (final side in walletSides(data, current))
          WalletPicker(
            label: side.sender
                ? context.l10n.walletFrom
                : context.l10n.walletTo,
            value: side.id,
            readOnly: current.type == TransactionTypes.walletTransferCode,
            onChanged: (id) => _reassign(context, current.tid, side.sender, id),
          ),
      ],
    );
  }

  Future<void> _reassign(
    BuildContext context,
    String tid,
    bool sender,
    String id,
  ) async {
    try {
      await WalletRepositoryImpl().assignTransaction(
        tid: tid,
        isSender: sender,
        walletId: id,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.walletError)));
      }
    }
  }
}

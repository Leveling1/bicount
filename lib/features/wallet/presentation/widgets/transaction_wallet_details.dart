import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_row.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/domain/services/wallet_attribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                child: _WalletDetailRow(
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

class _WalletDetailRow extends StatelessWidget {
  const _WalletDetailRow({
    required this.title,
    required this.wallet,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final WalletModel? wallet;
  final List<WalletModel> options;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final current = wallet;
    final change = onChanged;
    final row = TransactionDetailRow(
      title: title,
      content: current == null
          ? context.l10n.walletPrincipal
          : walletLabel(context, current),
      contentIcon: change == null ? null : Icons.expand_more,
      capitalizeContent: false,
    );
    if (change == null) return row;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            onPressed: option.id == current?.id
                ? null
                : () => change(option.id),
            child: Text(walletLabel(context, option)),
          ),
      ],
      builder: (context, menu, child) {
        void toggle() => menu.isOpen ? menu.close() : menu.open();
        return Semantics(
          button: true,
          child: FocusableActionDetector(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            },
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) => toggle(),
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggle,
              child: child,
            ),
          ),
        );
      },
      child: row,
    );
  }
}

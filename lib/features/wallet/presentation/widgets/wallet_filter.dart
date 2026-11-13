import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:flutter/material.dart';

class WalletFilter extends StatefulWidget {
  const WalletFilter({
    super.key,
    required this.walletId,
    required this.onChanged,
  });
  final String? walletId;
  final ValueChanged<String?> onChanged;

  @override
  State<WalletFilter> createState() => _WalletFilterState();
}

class _WalletFilterState extends State<WalletFilter> {
  final _wallets = WalletRepositoryImpl().watch();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalletModel>>(
      stream: _wallets,
      builder: (context, snapshot) {
        final wallets = snapshot.data ?? const [];
        final selected = wallets
            .where((wallet) => wallet.id == widget.walletId)
            .firstOrNull;
        return PopupMenuButton<String>(
          tooltip: context.l10n.walletPicker,
          onSelected: (id) => widget.onChanged(id.isEmpty ? null : id),
          itemBuilder: (context) => [
            PopupMenuItem(value: '', child: Text(context.l10n.walletAll)),
            for (final wallet in wallets)
              PopupMenuItem(
                value: wallet.id,
                child: Text(walletLabel(context, wallet)),
              ),
          ],
          child: Chip(
            avatar: const Icon(Icons.account_balance_wallet_outlined),
            label: Text(
              selected == null
                  ? context.l10n.walletAll
                  : walletLabel(context, selected),
            ),
          ),
        );
      },
    );
  }
}

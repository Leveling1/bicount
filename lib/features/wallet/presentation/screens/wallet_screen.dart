import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/wallet/presentation/screens/wallet_history.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_transfer_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void openWallets(BuildContext context) {
  final bloc = context.read<MainBloc>();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BlocProvider(
          create: (_) =>
              WalletBloc(WalletRepositoryImpl())..add(const WatchWallets()),
          child: const WalletScreen(),
        ),
      ),
    ),
  );
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final _repository = context.read<WalletBloc>().repository;
  late Future<List<WalletBalance>> _balances = _repository.balances();

  void _showHistory(WalletModel wallet) {
    final bloc = context.read<MainBloc>();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text(walletLabel(context, wallet))),
            body: BlocProvider.value(
              value: bloc,
              child: WalletHistory(walletId: wallet.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<MainBloc, MainState>(
      listener: (_, state) =>
          setState(() => _balances = _repository.balances()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.walletTitle),
          actions: [
            IconButton(
              tooltip: l10n.walletNew,
              icon: const Icon(Icons.add),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const WalletEditor(),
              ),
            ),
          ],
        ),
        body: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            final wallets = state.wallets;
            final active = wallets
                .where((wallet) => wallet.archivedAt == null)
                .toList();
            return FutureBuilder<List<WalletBalance>>(
              future: _balances,
              builder: (context, balanceSnapshot) {
                final balances = balanceSnapshot.data ?? const [];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (active.length > 1)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.swap_horiz),
                        label: Text(l10n.walletTransfer),
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => WalletTransferForm(wallets: active),
                        ),
                      ),
                    for (final wallet in wallets)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            walletIcons[wallet.icon],
                            color: walletColors[wallet.color],
                          ),
                          title: Text(walletLabel(context, wallet)),
                          subtitle: Text(
                            [
                              if (wallet.archivedAt != null)
                                l10n.walletArchived,
                              if (wallet.cardNetwork == WalletCardNetwork.visa)
                                'Visa',
                              if (wallet.cardNetwork ==
                                  WalletCardNetwork.mastercard)
                                'Mastercard',
                              for (final balance in balances.where(
                                (row) => row.walletId == wallet.id,
                              ))
                                NumberFormatUtils.formatCurrency(
                                  balance.minor / walletAmountScale,
                                  currencyCode: balance.currency,
                                ),
                            ].join(' · '),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.walletEdit,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed:
                                wallet.isDefault && wallet.createdAt.isEmpty
                                ? null
                                : () => showDialog<void>(
                                    context: context,
                                    builder: (_) =>
                                        WalletEditor(wallet: wallet),
                                  ),
                          ),
                          onTap: () => _showHistory(wallet),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/wallet/presentation/screens/wallet_history.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_overview_card.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_transfer_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final theme = Theme.of(context);
    return BlocListener<MainBloc, MainState>(
      listener: (_, state) =>
          setState(() => _balances = _repository.balances()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 28,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(l10n.walletTitle, style: theme.textTheme.titleMedium),
          actions: [
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                final active = state.wallets
                    .where((wallet) => wallet.archivedAt == null)
                    .toList();
                if (active.length < 2) return const SizedBox.shrink();
                return IconButton(
                  tooltip: l10n.walletTransfer,
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => WalletTransferForm(wallets: active),
                  ),
                );
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface,
                foregroundColor: theme.colorScheme.surface,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: theme.textTheme.labelMedium,
              ),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const WalletEditor(),
              ),
              child: Text(l10n.walletNew),
            ),
            const SizedBox(width: 24),
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
                  padding: const EdgeInsets.fromLTRB(28, 6, 28, 88),
                  children: [
                    for (final wallet in [
                      ...active,
                      ...wallets.where((wallet) => wallet.archivedAt != null),
                    ])
                      Padding(
                        key: ValueKey(wallet.id),
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WalletOverviewCard(
                          wallet: wallet,
                          balances: balances
                              .where((row) => row.walletId == wallet.id)
                              .toList(),
                          onEdit: wallet.isDefault && wallet.createdAt.isEmpty
                              ? null
                              : () => showDialog<void>(
                                  context: context,
                                  builder: (_) => WalletEditor(wallet: wallet),
                                ),
                          onHistory: () => _showHistory(wallet),
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

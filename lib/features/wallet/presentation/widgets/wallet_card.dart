import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_balance_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_stack.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.data,
    required this.walletId,
    required this.onChanged,
  });

  final MainEntity data;
  final String? walletId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final wallets = <WalletModel?>[null, ...state.wallets];
        final index = wallets.indexWhere((wallet) => wallet?.id == walletId);
        final selectedIndex = index < 0 ? 0 : index;
        final wallet = wallets[selectedIndex];
        void select(int index) => onChanged(wallets[index]?.id);

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall,
          ),
          child: Column(
            children: [
              WalletCardStack(
                wallets: wallets,
                selectedIndex: selectedIndex,
                onChanged: select,
                balanceBuilder: (wallet) =>
                    WalletBalanceText(walletId: wallet?.id),
              ),
              Row(
                children: [
                  Expanded(
                    child: PopupMenuButton<int>(
                      tooltip: context.l10n.walletPicker,
                      initialValue: selectedIndex,
                      onSelected: select,
                      itemBuilder: (context) => [
                        for (final (index, wallet) in wallets.indexed)
                          PopupMenuItem(
                            value: index,
                            child: Text(_label(context, wallet)),
                          ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.paddingSmall,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _label(context, wallet),
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.expand_more, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (wallets.length > 1)
                    Semantics(
                      label: '${selectedIndex + 1} / ${wallets.length}',
                      child: Row(
                        children: [
                          for (
                            var i = 0;
                            i < wallets.length && wallets.length <= 7;
                            i++
                          )
                            Container(
                              margin: const EdgeInsetsDirectional.only(
                                start: 4,
                              ),
                              width: i == selectedIndex ? 14 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: i == selectedIndex
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          if (wallets.length > 7)
                            ExcludeSemantics(
                              child: Text(
                                '${selectedIndex + 1} / ${wallets.length}',
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: wallet == null
                    ? DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.bodySmall,
                        child: const WalletBalanceText(),
                      )
                    : Text(
                        state.balances == null
                            ? '—'
                            : state.balances!
                                  .where(
                                    (balance) => balance.walletId == wallet.id,
                                  )
                                  .isEmpty
                            ? context.l10n.walletNoMovements
                            : state.balances!
                                  .where(
                                    (balance) => balance.walletId == wallet.id,
                                  )
                                  .map(
                                    (balance) =>
                                        NumberFormatUtils.formatCurrency(
                                          balance.minor / walletAmountScale,
                                          currencyCode: balance.currency,
                                        ),
                                  )
                                  .join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _label(BuildContext context, WalletModel? wallet) =>
      wallet == null ? context.l10n.walletAll : walletLabel(context, wallet);
}

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_stack.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:flutter/material.dart';

class WalletCard extends StatefulWidget {
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
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  final _repository = WalletRepositoryImpl();
  late final _wallets = _repository.watch();
  late Future<List<WalletBalance>> _balances = _repository.balances();

  @override
  void didUpdateWidget(WalletCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.transactions != oldWidget.data.transactions ||
        widget.data.friends != oldWidget.data.friends) {
      _balances = _repository.balances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalletModel>>(
      stream: _wallets,
      builder: (context, snapshot) {
        final wallets = <WalletModel?>[null, ...?snapshot.data];
        final index = wallets.indexWhere(
          (wallet) => wallet?.id == widget.walletId,
        );
        final selectedIndex = index < 0 ? 0 : index;
        final wallet = wallets[selectedIndex];
        void select(int index) => widget.onChanged(wallets[index]?.id);

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
                    ? Text(
                        NumberFormatUtils.formatCurrency(
                          widget.data.user.balance ?? 0,
                          currencyCode: widget.data.referenceCurrencyCode,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : FutureBuilder<List<WalletBalance>>(
                        future: _balances,
                        builder: (context, snapshot) {
                          final amounts =
                              (snapshot.data ?? const <WalletBalance>[])
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
                                  .join(' · ');
                          return Text(
                            amounts.isEmpty && snapshot.hasData
                                ? context.l10n.walletNoMovements
                                : amounts,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
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

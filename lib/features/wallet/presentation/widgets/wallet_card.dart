import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/widgets/app_popup_menu_item.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/dropdown_chevron_theme.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
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
    required this.wallets,
    required this.walletId,
    required this.onChanged,
  });

  final List<WalletModel> wallets;
  final String? walletId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) return const SizedBox.shrink();
    final index = wallets.indexWhere((wallet) => wallet.id == walletId);
    final selectedIndex = index < 0 ? 0 : index;
    final wallet = wallets[selectedIndex];
    final balances = context.select((WalletBloc bloc) => bloc.state.balances);
    final amounts = balances
        ?.where((balance) => balance.walletId == wallet.id)
        .map(
          (balance) => NumberFormatUtils.formatCurrency(
            balance.minor / walletAmountScale,
            currencyCode: balance.currency,
          ),
        )
        .join(' · ');
    void select(int index) => onChanged(wallets[index].id);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium,
        vertical: AppDimens.paddingSmall,
      ),
      child: Column(
        children: [
          WalletCardStack(
            key: ValueKey(wallets.map((wallet) => wallet.id).join(',')),
            wallets: wallets,
            loop: true,
            selectedIndex: selectedIndex,
            onChanged: select,
            balanceBuilder: (wallet) => WalletBalanceText(walletId: wallet?.id),
          ),
          Row(
            children: [
              Expanded(
                child: BicountPressable.control(
                  child: PopupMenuButton<int>(
                    tooltip: context.l10n.walletPicker,
                    initialValue: selectedIndex,
                    clipBehavior: Clip.antiAlias,
                    onSelected: select,
                    itemBuilder: (context) => [
                      for (final (index, wallet) in wallets.indexed)
                        AppPopupMenuItem(
                          value: index,
                          child: Text(walletLabel(context, wallet)),
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
                              walletLabel(context, wallet),
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownChevronTheme.of(context).icon(),
                        ],
                      ),
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
                            start: AppDimens.paddingExtraSmall,
                          ),
                          width: i == selectedIndex
                              ? AppSizes.dp14
                              : AppSizes.dp5,
                          height: AppSizes.dp5,
                          decoration: BoxDecoration(
                            color: i == selectedIndex
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadiusExtraSmall,
                            ),
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
          if (amounts != null && amounts.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                amounts,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

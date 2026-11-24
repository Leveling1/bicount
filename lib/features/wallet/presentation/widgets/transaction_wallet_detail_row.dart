import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/themes/dropdown_chevron_theme.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_detail_row.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionWalletDetailRow extends StatelessWidget {
  const TransactionWalletDetailRow({
    super.key,
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
      trailing: change == null
          ? null
          : DropdownChevronTheme.of(
              context,
            ).icon(color: Theme.of(context).textTheme.bodyMedium?.color),
      capitalizeContent: false,
    );
    if (change == null) return row;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(192.0, constraints.maxWidth);
        return MenuAnchor(
          alignmentOffset: Offset(-width, AppDimens.spacingExtraSmall),
          crossAxisUnconstrained: false,
          style: MenuStyle(
            alignment: AlignmentDirectional.bottomEnd,
            fixedSize: WidgetStatePropertyAll(Size.fromWidth(width)),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppDimens.borderRadiusMedium),
                ),
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          menuChildren: [
            for (final option in options)
              MenuItemButton(
                onPressed: option.id == current?.id
                    ? null
                    : () => change(option.id),
                child: Text(
                  walletLabel(context, option),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
      },
    );
  }
}

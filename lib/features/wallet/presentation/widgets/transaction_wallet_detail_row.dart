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

  Future<void> _showWalletMenu(
    BuildContext context,
    ValueChanged<String> change,
  ) async {
    final overlay = Navigator.of(context).overlay!;
    final overlayBox = overlay.context.findRenderObject()! as RenderBox;
    final row = context.findRenderObject()! as RenderBox;
    final bounds =
        row.localToGlobal(Offset.zero, ancestor: overlayBox) & row.size;
    final direction = Directionality.of(context);
    final x = direction == TextDirection.ltr ? bounds.right : bounds.left;
    final items = [
      for (final option in options)
        PopupMenuItem(
          value: option.id,
          child: Text(walletLabel(context, option)),
        ),
    ];
    final padding = MediaQuery.paddingOf(overlay.context);
    final menuPadding =
        PopupMenuTheme.of(context).menuPadding ??
        const EdgeInsets.symmetric(vertical: AppDimens.paddingSmall);
    final menuHeight = items.fold(
      menuPadding.vertical,
      (height, item) => height + item.height,
    );
    final below = bounds.bottom + AppDimens.spacingExtraSmall;
    final above = bounds.top - AppDimens.spacingExtraSmall;
    final fitsBelow =
        below + menuHeight <=
        overlayBox.size.height - padding.bottom - AppDimens.paddingSmall;
    final fitsAbove =
        above - menuHeight >= padding.top + AppDimens.paddingSmall;
    final top = !fitsBelow && fitsAbove ? above - menuHeight : below;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromSize(
        Rect.fromLTWH(x, top, 0, 0),
        overlayBox.size,
      ),
      items: items,
      initialValue: wallet?.id,
      clipBehavior: Clip.antiAlias,
    );
    if (context.mounted && selected != null && selected != wallet?.id) {
      change(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = wallet;
    final change = options.length > 1 ? onChanged : null;
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

    return Semantics(
      button: true,
      child: FocusableActionDetector(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _showWalletMenu(context, change),
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showWalletMenu(context, change),
          child: row,
        ),
      ),
    );
  }
}

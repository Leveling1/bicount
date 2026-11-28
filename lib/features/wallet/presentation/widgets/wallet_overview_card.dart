import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/constants/icon_links.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_flight.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_balance_text.dart';
import 'package:flutter/material.dart';

class WalletOverviewCard extends StatelessWidget {
  const WalletOverviewCard({
    super.key,
    required this.wallet,
    required this.balances,
    required this.onTransactions,
    required this.onEdit,
  });

  final WalletModel wallet;
  final List<WalletBalance> balances;
  final VoidCallback onTransactions;
  final VoidCallback? onEdit;

  static const double aspectRatio = 1.84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final flight = WalletCardFlight.maybeOf(context);
    final moving = flight?.movingIds.contains(wallet.id) ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.dp20),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: SizedBox.expand(
                  key: flight?.geometry.anchor(
                    WalletCardEndpoint.list,
                    wallet.id,
                  ),
                  child: moving
                      ? null
                      : WalletCardFace(
                          wallet: wallet,
                          balance: WalletBalanceText(walletId: wallet.id),
                          showDetails: true,
                          onTap: onTransactions,
                        ),
                ),
              ),
            ),
            if (!moving)
              PositionedDirectional(
                start: AppSizes.dp8,
                bottom: 0,
                child: WalletOverviewActions(
                  wallet: wallet,
                  onTransactions: onTransactions,
                  onEdit: onEdit,
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppDimens.paddingSmallMedium,
            top: AppDimens.paddingExtraSmall,
          ),
          child: Visibility(
            visible: !moving,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Wrap(
              spacing: AppSizes.dp12,
              runSpacing: AppDimens.spacingExtraSmall,
              children: [
                if (wallet.archivedAt != null)
                  Text(l10n.walletArchived, style: theme.textTheme.labelMedium),
                if (balances.isEmpty)
                  Text(
                    l10n.walletNoMovements,
                    style: theme.textTheme.labelMedium,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WalletOverviewActions extends StatelessWidget {
  const WalletOverviewActions({
    super.key,
    required this.wallet,
    this.onTransactions,
    this.onEdit,
    this.decorative = false,
  });

  final WalletModel wallet;
  final VoidCallback? onTransactions;
  final VoidCallback? onEdit;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = walletMetal(wallet);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WalletCardAction(
          tint: tint,
          label: l10n.navTransaction,
          icon: SvgPicture.asset(
            IconLinks.transaction,
            width: AppSizes.dp16,
            height: AppSizes.dp16,
            excludeFromSemantics: true,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          onPressed: onTransactions,
          decorative: decorative,
        ),
        const SizedBox(width: AppDimens.spacingExtraSmall),
        _WalletCardAction(
          tint: tint,
          label: l10n.walletEdit,
          icon: const Icon(Icons.edit, size: AppDimens.iconSizeSmall),
          onPressed: onEdit,
          decorative: decorative,
        ),
      ],
    );
  }
}

class _WalletCardAction extends StatelessWidget {
  const _WalletCardAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.tint,
    required this.decorative,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color tint;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = Color.alphaBlend(
      tint.withValues(alpha: .24),
      colors.surfaceContainerHighest,
    );
    return BicountPressable.control(
      enabled: !decorative && onPressed != null,
      child: IconButton(
        tooltip: decorative ? null : label,
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: colors.onSurface,
          minimumSize: const Size(AppSizes.dp34, AppSizes.dp34),
          padding: EdgeInsets.zero,
        ),
        icon: icon,
        onPressed: decorative ? () {} : onPressed,
      ),
    );
  }
}

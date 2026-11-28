part of 'wallet_card_face.dart';

class _WalletMarkings extends StatelessWidget {
  const _WalletMarkings({required this.wallet, this.balance});

  final WalletModel? wallet;
  final Widget? balance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wallet = this.wallet;
    final kind = wallet?.kind;
    final kindLabel = kind == null
        ? l10n.walletAll
        : walletKindLabel(context, kind);
    final operator = wallet?.mobileOperator;
    final logo = switch (kind) {
      WalletKind.card => walletNetworkLogo(wallet?.cardNetwork),
      WalletKind.mobileMoney when operator != null => walletOperatorLogo(
        operator,
      ),
      _ => null,
    };
    final logoLabel = switch (kind) {
      WalletKind.mobileMoney when operator != null => walletOperatorLabel(
        operator,
      ),
      WalletKind.card =>
        wallet?.cardNetwork == WalletCardNetwork.visa ? 'Visa' : 'Mastercard',
      _ => null,
    };
    final iconColor = DefaultTextStyle.of(context).style.color;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                kindLabel.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  letterSpacing: AppSizes.dp1Point35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SvgPicture.asset(
              walletKindIcon(kind ?? WalletKind.other),
              width: AppSizes.dp22,
              height: AppSizes.dp22,
              colorFilter: iconColor == null
                  ? null
                  : ColorFilter.mode(iconColor, BlendMode.srcIn),
              excludeFromSemantics: true,
            ),
          ],
        ),
        if (balance != null)
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    fontSize: AppSizes.dp26,
                    fontWeight: FontWeight.w600,
                  ),
                  child: balance!,
                ),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                wallet == null ? l10n.appName : walletLabel(context, wallet),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: AppSizes.dp0Point45,
                ),
              ),
            ),
            if (logo != null) ...[
              const SizedBox(width: AppDimens.spacingSmall),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SvgPicture.asset(
                    logo,
                    width: AppSizes.dp62,
                    height: AppSizes.dp24,
                    semanticsLabel: logoLabel,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

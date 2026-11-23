part of 'wallet_card_face.dart';

class _WalletMarkings extends StatelessWidget {
  const _WalletMarkings({required this.wallet, this.balance});

  final WalletModel? wallet;
  final Widget? balance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wallet = this.wallet;
    final kind = switch (wallet?.kind) {
      WalletKind.bankAccount => l10n.walletBank,
      WalletKind.cash => l10n.walletCash,
      WalletKind.card => l10n.walletCard,
      WalletKind.mobileMoney => l10n.walletMobile,
      WalletKind.other => l10n.walletOther,
      null => l10n.walletAll,
    };
    final network = switch (wallet?.cardNetwork) {
      WalletCardNetwork.visa => 'VISA',
      WalletCardNetwork.mastercard => 'mastercard',
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
                kind.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  letterSpacing: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (wallet?.kind == WalletKind.card)
              Transform.rotate(
                angle: -math.pi / 2,
                child: Icon(
                  Icons.contactless_outlined,
                  size: 24,
                  color: iconColor,
                ),
              )
            else
              Icon(walletIcons[wallet?.icon ?? 0], size: 22, color: iconColor),
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
                    fontSize: 26,
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
              child: Text(
                wallet == null ? l10n.appName : walletLabel(context, wallet),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: .45,
                ),
              ),
            ),
            if (network != null)
              Text(
                network,
                style: TextStyle(
                  fontSize: network == 'VISA' ? 25 : 17,
                  height: 1,
                  fontStyle: network == 'VISA'
                      ? FontStyle.italic
                      : FontStyle.normal,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

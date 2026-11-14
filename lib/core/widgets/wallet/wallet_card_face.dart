import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:flutter/material.dart';

part 'wallet_brushed_finish.dart';

class WalletCardFace extends StatelessWidget {
  const WalletCardFace({
    super.key,
    required this.wallet,
    required this.showDetails,
    this.onTap,
    this.detailsOpacity = 1,
  });

  static const aspectRatio = 1.59;

  final VoidCallback? onTap;
  final WalletModel? wallet;
  final bool showDetails;
  final double detailsOpacity;

  @override
  Widget build(BuildContext context) {
    final wallet = this.wallet;
    final metal = walletMetal(wallet);
    const ink = Color(0xFF25231F);
    final radius = BorderRadius.circular(14);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x330D0C09),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, .38, .67, 1],
              colors: [
                Color.lerp(metal, Colors.white, .28)!,
                metal,
                Color.lerp(metal, Colors.white, .14)!,
                Color.lerp(metal, const Color(0xFF514A41), .14)!,
              ],
            ),
          ),
          child: CustomPaint(
            painter: const _BrushedFinish(),
            child: onTap == null
                ? _details(ink, wallet)
                : Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onTap, child: _details(ink, wallet)),
                  ),
          ),
        ),
      ),
    );
  }

  Widget? _details(Color ink, WalletModel? wallet) {
    if (!showDetails || detailsOpacity == 0) return null;
    final details = Padding(
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: TextStyle(color: ink, fontSize: 11),
        child: _WalletMarkings(wallet: wallet),
      ),
    );
    return detailsOpacity == 1
        ? details
        : Opacity(opacity: detailsOpacity, child: details);
  }
}

class _WalletMarkings extends StatelessWidget {
  const _WalletMarkings({required this.wallet});

  final WalletModel? wallet;

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
    return ExcludeSemantics(
      child: Column(
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
                Icon(
                  walletIcons[wallet?.icon ?? 0],
                  size: 22,
                  color: iconColor,
                ),
            ],
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
      ),
    );
  }
}

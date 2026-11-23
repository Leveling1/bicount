import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:flutter/material.dart';

part 'wallet_brushed_finish.dart';
part 'wallet_card_markings.dart';

class WalletCardFace extends StatelessWidget {
  const WalletCardFace({
    super.key,
    required this.wallet,
    required this.showDetails,
    this.onTap,
    this.detailsOpacity = 1,
    this.balance,
  });

  static const aspectRatio = 1.59;

  final VoidCallback? onTap;
  final WalletModel? wallet;
  final bool showDetails;
  final double detailsOpacity;
  final Widget? balance;

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
        child: _WalletMarkings(wallet: wallet, balance: balance),
      ),
    );
    return detailsOpacity == 1
        ? details
        : Opacity(opacity: detailsOpacity, child: details);
  }
}

import 'dart:math' as math;

import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/core/widgets/wallet/wallet_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final radius = BorderRadius.circular(AppSizes.dp14);
    final face = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x330D0C09),
            offset: Offset(0, AppSizes.dp3),
            blurRadius: AppSizes.dp8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: walletFinishGradient(metal)),
          child: CustomPaint(
            painter: const _BrushedFinish(),
            child: _details(ink, wallet),
          ),
        ),
      ),
    );
    return onTap == null
        ? face
        : BicountPressable(onTap: onTap, borderRadius: radius, child: face);
  }

  Widget? _details(Color ink, WalletModel? wallet) {
    if (!showDetails || detailsOpacity == 0) return null;
    final details = Padding(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: DefaultTextStyle(
        style: TextStyle(color: ink, fontSize: AppSizes.dp11),
        child: _WalletMarkings(wallet: wallet, balance: balance),
      ),
    );
    return detailsOpacity == 1
        ? details
        : Opacity(opacity: detailsOpacity, child: details);
  }
}

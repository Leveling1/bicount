import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_editor.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_picker.dart';
import 'package:flutter/material.dart';

class WalletCardFace extends StatelessWidget {
  const WalletCardFace({
    super.key,
    required this.wallet,
    required this.showDetails,
  });

  final WalletModel? wallet;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final wallet = this.wallet;
    final metal = wallet == null || wallet.isDefault
        ? const Color(0xFFCDC7BE)
        : switch (wallet.color) {
            0 => const Color(0xFFC2C7CE),
            4 => const Color(0xFFDBC28E),
            final index => Color.lerp(
              const Color(0xFFCDD0D1),
              walletColors[index],
              .24,
            )!,
          };
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
            child: showDetails
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: DefaultTextStyle(
                      style: TextStyle(color: ink, fontSize: 11),
                      child: _WalletMarkings(wallet: wallet),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
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

class _BrushedFinish extends CustomPainter {
  const _BrushedFinish();

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Paint()..color = const Color(0x0C4F4535);
    final light = Paint()..color = const Color(0x22FFFFFF);
    for (var y = 1.0; y < size.height; y += 2.5) {
      final end = size.width * (.62 + .38 * (1 + math.sin(y * 1.9)) / 2);
      canvas.drawLine(Offset(0, y), Offset(end, y), dark);
      canvas.drawLine(
        Offset(size.width - end, y + 1),
        Offset(size.width, y + 1),
        light,
      );
    }
  }

  @override
  bool shouldRepaint(_BrushedFinish oldDelegate) => false;
}

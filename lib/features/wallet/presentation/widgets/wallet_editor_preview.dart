import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:flutter/material.dart';

class WalletEditorPreview extends StatelessWidget {
  const WalletEditorPreview({
    super.key,
    required this.name,
    required this.kind,
    required this.color,
    this.wallet,
    this.network,
    this.mobileOperator,
  });

  final TextEditingController name;
  final WalletModel? wallet;
  final WalletKind kind;
  final WalletCardNetwork? network;
  final WalletMobileOperator? mobileOperator;
  final int color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: name,
      builder: (context, value, _) {
        final label = value.text.trim();
        final draft = WalletModel(
          id: wallet?.id ?? 'wallet-preview',
          ownerUid: wallet?.ownerUid ?? '',
          name: label.isEmpty ? context.l10n.walletName : label,
          createdAt: wallet?.createdAt ?? '',
          isDefault: wallet?.isDefault ?? false,
          kind: kind,
          cardNetwork: kind == WalletKind.card ? network : null,
          mobileOperator: kind == WalletKind.mobileMoney
              ? mobileOperator
              : null,
          icon: kind.legacyIcon,
          color: color,
        );
        return _FloatingWalletCard(wallet: draft);
      },
    );
  }
}

class _FloatingWalletCard extends StatefulWidget {
  const _FloatingWalletCard({required this.wallet});

  final WalletModel wallet;

  @override
  State<_FloatingWalletCard> createState() => _FloatingWalletCardState();
}

class _FloatingWalletCardState extends State<_FloatingWalletCard>
    with SingleTickerProviderStateMixin {
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _float.stop();
      _float.value = 0;
    } else if (!_float.isAnimating) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(
            math.min(320.0, math.max(0.0, constraints.maxWidth - 32)),
            math.max(0.0, constraints.maxHeight - 32) *
                WalletCardFace.aspectRatio,
          );
          final height = width / WalletCardFace.aspectRatio;
          return SizedBox(
            height: height + 32,
            child: Center(
              child: SizedBox(
                width: width,
                height: height,
                child: AnimatedBuilder(
                  animation: _float,
                  child: RepaintBoundary(
                    child: FittedBox(
                      child: SizedBox(
                        width: 320,
                        height: 320 / WalletCardFace.aspectRatio,
                        child: WalletCardFace(
                          wallet: widget.wallet,
                          showDetails: true,
                        ),
                      ),
                    ),
                  ),
                  builder: (context, card) => Transform.translate(
                    offset: Offset(
                      0,
                      4 * Curves.easeInOutSine.transform(_float.value),
                    ),
                    child: card,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

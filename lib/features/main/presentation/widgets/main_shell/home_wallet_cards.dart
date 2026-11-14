import 'package:bicount/core/widgets/wallet/wallet_card_face.dart';
import 'package:bicount/features/wallet/data/models/wallet_model.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_overview_card.dart';
import 'package:flutter/material.dart';

class HomeWalletCardPath {
  const HomeWalletCardPath(this.wallet, this.preview, this.destination);

  final WalletModel wallet;
  final Rect preview;
  final Rect destination;
}

class HomeWalletCards extends StatelessWidget {
  const HomeWalletCards({
    super.key,
    required this.paths,
    required this.progress,
  });

  final List<HomeWalletCardPath> paths;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (index, path) in paths.indexed)
              _card(path, index, direction),
          ],
        ),
      ),
    );
  }

  Widget _card(HomeWalletCardPath path, int index, int direction) {
    final arrival = index == 0 ? .68 : .96;
    final fanEnd = .55 + index * .045;
    final first = paths.first.destination;
    final staging = Rect.fromLTWH(
      path.destination.left + index * 24 * direction,
      first.top + index * 7,
      path.destination.width,
      path.destination.height,
    );
    final rect = progress <= fanEnd
        ? Rect.lerp(path.preview, staging, progress / fanEnd)!
        : Rect.lerp(
            staging,
            path.destination,
            Curves.easeOutCubic.transform(_interval(fanEnd, arrival)),
          )!;
    final actions = _interval(.32 + index * .09, .62 + index * .09);
    return Positioned.fromRect(
      rect: rect,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          WalletCardFace(
            wallet: path.wallet,
            showDetails: true,
            detailsOpacity: _interval(.28, .67),
          ),
          if (actions > 0)
            PositionedDirectional(
              start: 8,
              bottom: -20,
              child: Opacity(
                opacity: actions,
                child: WalletOverviewActions(
                  wallet: path.wallet,
                  decorative: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _interval(double start, double end) =>
      ((progress - start) / (end - start)).clamp(0.0, 1.0);
}

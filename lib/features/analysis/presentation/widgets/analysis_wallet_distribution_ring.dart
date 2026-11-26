import 'dart:math' as math;

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnalysisWalletDistributionRing extends StatelessWidget {
  const AnalysisWalletDistributionRing({
    super.key,
    required this.totalLabel,
    required this.slices,
  });

  final String totalLabel;
  final List<({double amount, Color color})> slices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 208.0);
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CustomPaint(painter: _WalletRingPainter(slices)),
                  ),
                ),
                SizedBox(
                  width: size * .57,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.analysisWalletPositiveTotal,
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(totalLabel, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletRingPainter extends CustomPainter {
  const _WalletRingPainter(this.slices);

  final List<({double amount, Color color})> slices;

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty || size.isEmpty) return;

    final count = slices.length;
    final diameter = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = diameter * .395;
    final halfThickness = diameter * .065;
    if (count == 1) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = slices.single.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = halfThickness * 2,
      );
      return;
    }

    const fullTurn = 2 * math.pi;
    final gap = math.min(math.pi / 90, fullTurn / count * .12);
    final usableTurn = fullTurn - gap * count;
    final averageSweep = usableTurn / count;
    final capAngle = math.min(
      math.asin(halfThickness / radius),
      averageSweep * .4,
    );
    final minimumSweep = 2 * capAngle + math.min(.02, averageSweep * .1);
    final strokeWidth = 2 * radius * math.sin(capAngle);
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.amount);
    final sweeps = slices
        .map((slice) => slice.amount / total * usableTurn)
        .toList();

    // Make room for a visible round cap on tiny shares. Redistribute only
    // the needed angle from larger shares so ordinary slices keep their size.
    var missingAngle = 0.0;
    var spareAngle = 0.0;
    for (final sweep in sweeps) {
      missingAngle += math.max(0.0, minimumSweep - sweep);
      spareAngle += math.max(0.0, sweep - minimumSweep);
    }
    final reduction = spareAngle == 0 ? 0.0 : missingAngle / spareAngle;
    final circle = Rect.fromCircle(center: center, radius: radius);
    var angle = -math.pi / 2;
    for (final (index, slice) in slices.indexed) {
      final sweep =
          minimumSweep +
          math.max(0.0, sweeps[index] - minimumSweep) * (1 - reduction);
      canvas.drawArc(
        circle,
        angle + gap / 2 + capAngle,
        sweep - 2 * capAngle,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      angle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _WalletRingPainter oldDelegate) =>
      !listEquals(slices, oldDelegate.slices);
}

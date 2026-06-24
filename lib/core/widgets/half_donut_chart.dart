import 'dart:math';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────────────────────
class ChartSegment {
  final String label;
  final double value;
  final Color color;
  final String displayCurrencyCode;

  const ChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.displayCurrencyCode,
  });
}

// ─── Half Donut Chart Widget ──────────────────────────────────
class HalfDonutChart extends StatelessWidget {
  final double total;
  final String currencyCode;
  final List<ChartSegment> segments;
  final String? centerLabel;
  final String? centerSubLabel;
  final double size;
  final double strokeWidth;
  final double gapDegrees;
  final TextStyle? centerLabelStyle;
  final TextStyle? centerSubLabelStyle;
  final TextStyle? legendLabelStyle;
  final TextStyle? legendValueStyle;

  const HalfDonutChart({
    super.key,
    required this.total,
    required this.currencyCode,
    required this.segments,
    this.centerLabel,
    this.centerSubLabel,
    this.size = 260,
    this.strokeWidth = 18,
    this.gapDegrees = 5,
    this.centerLabelStyle,
    this.centerSubLabelStyle,
    this.legendLabelStyle,
    this.legendValueStyle,
  });

  double get _total => segments.fold(0, (sum, s) => sum + s.value);
  static const _compactThreshold = 100000;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Chart ──
        SizedBox(
          width: size,
          height: size * 0.55, // half-donut only needs ~half height
          child: CustomPaint(
            size: Size(size, size * 0.55),
            painter: _HalfDonutPainter(
              segments: segments,
              total: _total,
              strokeWidth: strokeWidth,
              gapDegrees: gapDegrees,
              trackColor: Theme.of(context).cardColor,
            ),
            child: _buildCenterText(context),
          ),
        ),

        const SizedBox(height: 28),

        // ── Legend ──
        _buildLegend(context),
      ],
    );
  }

  Widget _buildCenterText(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: total),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) {
              return Text(
                NumberFormatUtils.compactCurrency(
                  animatedValue,
                  currencyCode: currencyCode,
                  compactThreshold: _compactThreshold,
                  thousandSuffix: 'k',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    centerLabelStyle ??
                    TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
              );
            },
          ),
          if (centerSubLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              centerSubLabel!,
              style:
                  centerSubLabelStyle ??
                  TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: segments.map((segment) {
        final percentage = (_total > 0)
            ? (segment.value / _total * 100).toStringAsFixed(0)
            : '0';

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: segment.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                segment.label,
                style:
                    legendLabelStyle ??
                    TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 13,
                    ),
              ),
            ),
            Text(
              '${NumberFormatUtils.formatCurrency(segment.value, currencyCode: segment.displayCurrencyCode)} | $percentage%',
              style:
                  legendValueStyle ??
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Custom Painter ───────────────────────────────────────────
class _HalfDonutPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double total;
  final double strokeWidth;
  final double gapDegrees;
  final Color trackColor;

  _HalfDonutPainter({
    required this.segments,
    required this.total,
    required this.strokeWidth,
    required this.gapDegrees,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    // Arc spans 180° (pi radians), from left (π) to right (0 / 2π).
    const totalSweep = pi; // 180 degrees
    final gapRad = gapDegrees * pi / 180;
    final totalGap = gapRad * segments.length;
    final usableSweep = totalSweep - totalGap;

    // ── Background track ──
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // start at left (180°)
      totalSweep,
      false,
      trackPaint,
    );

    // ── Segments ──
    double currentAngle = pi; // start at left

    for (final segment in segments) {
      final fraction = (total > 0) ? segment.value / total : 0;
      final sweep = usableSweep * fraction;

      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle + gapRad / 2,
        sweep,
        false,
        segmentPaint,
      );

      currentAngle += sweep + gapRad;
    }
  }

  @override
  bool shouldRepaint(covariant _HalfDonutPainter old) =>
      old.segments != segments ||
      old.total != total ||
      old.strokeWidth != strokeWidth;
}

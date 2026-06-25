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
class HalfDonutChart extends StatefulWidget {
  final double total;
  final String currencyCode;
  final List<ChartSegment> segments;
  final String? centerSubLabel;
  final double size;
  final double strokeWidth;
  final double gapDegrees;
  final Duration animationDuration;
  final Curve animationCurve;
  final TextStyle? centerLabelStyle;
  final TextStyle? centerSubLabelStyle;
  final TextStyle? legendLabelStyle;
  final TextStyle? legendValueStyle;

  const HalfDonutChart({
    super.key,
    required this.total,
    required this.currencyCode,
    required this.segments,
    this.centerSubLabel,
    this.size = 260,
    this.strokeWidth = 18,
    this.gapDegrees = 5,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeInOutCubic,
    this.centerLabelStyle,
    this.centerSubLabelStyle,
    this.legendLabelStyle,
    this.legendValueStyle,
  });

  @override
  State<HalfDonutChart> createState() => _HalfDonutChartState();
}

class _HalfDonutChartState extends State<HalfDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Snapshots for lerping
  List<double> _oldValues = [];
  List<double> _newValues = [];
  double _oldTotal = 0;
  double _newTotal = 0;

  static const _compactThreshold = 100000;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _newValues = widget.segments.map((s) => s.value).toList();
    _oldValues = List.filled(_newValues.length, 0);
    _newTotal = widget.total;
    _oldTotal = 0;

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HalfDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dataChanged =
        oldWidget.total != widget.total ||
        oldWidget.segments.length != widget.segments.length ||
        _segmentsChanged(oldWidget.segments, widget.segments);

    if (!dataChanged) return;

    // Snapshot current animated values as the new "old"
    final t = _animation.value;
    _oldValues = _lerpedValues(t);
    _oldTotal = _lerpDouble(_oldTotal, _newTotal, t);

    // Set new targets
    _newValues = widget.segments.map((s) => s.value).toList();
    _newTotal = widget.total;

    // Pad if segment count changed
    _padLists();

    _controller
      ..reset()
      ..forward();
  }

  bool _segmentsChanged(List<ChartSegment> a, List<ChartSegment> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value || a[i].color != b[i].color) return true;
    }
    return false;
  }

  void _padLists() {
    while (_oldValues.length < _newValues.length) {
      _oldValues.add(0);
    }
    while (_newValues.length < _oldValues.length) {
      _newValues.add(0);
    }
  }

  List<double> _lerpedValues(double t) {
    final count = max(_oldValues.length, _newValues.length);
    return List.generate(count, (i) {
      final from = i < _oldValues.length ? _oldValues[i] : 0.0;
      final to = i < _newValues.length ? _newValues[i] : 0.0;
      return _lerpDouble(from, to, t);
    });
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        final animatedValues = _lerpedValues(t);
        final animatedTotal = animatedValues.fold<double>(0, (s, v) => s + v);
        final displayTotal = _lerpDouble(_oldTotal, _newTotal, t);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Chart ──
            SizedBox(
              width: widget.size,
              height: widget.size * 0.55,
              child: CustomPaint(
                size: Size(widget.size, widget.size * 0.55),
                painter: _HalfDonutPainter(
                  values: animatedValues,
                  colors: widget.segments.map((s) => s.color).toList(),
                  total: animatedTotal,
                  strokeWidth: widget.strokeWidth,
                  gapDegrees: widget.gapDegrees,
                  trackColor: Theme.of(context).cardColor,
                ),
                child: _buildCenterText(context, displayTotal),
              ),
            ),
            const SizedBox(height: 28),
            // ── Legend ──
            _buildLegend(context, animatedValues, animatedTotal),
          ],
        );
      },
    );
  }

  Widget _buildCenterText(BuildContext context, double displayTotal) {
    return Align(
      alignment: const Alignment(0, 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormatUtils.compactCurrency(
              displayTotal,
              currencyCode: widget.currencyCode,
              compactThreshold: _compactThreshold,
              thousandSuffix: 'k',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                widget.centerLabelStyle ??
                TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
          ),
          if (widget.centerSubLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.centerSubLabel!,
              style:
                  widget.centerSubLabelStyle ??
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

  Widget _buildLegend(
    BuildContext context,
    List<double> animatedValues,
    double animatedTotal,
  ) {
    return Column(
      children: List.generate(widget.segments.length, (i) {
        final segment = widget.segments[i];
        final value = i < animatedValues.length ? animatedValues[i] : 0.0;
        final percentage = animatedTotal > 0
            ? (value / animatedTotal * 100).round()
            : 0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: i < widget.segments.length - 1 ? 14 : 0,
          ),
          child: Row(
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
                      widget.legendLabelStyle ??
                      TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 13,
                      ),
                ),
              ),
              Text(
                '${NumberFormatUtils.formatCurrency(value, currencyCode: segment.displayCurrencyCode)} | $percentage%',
                style:
                    widget.legendValueStyle ??
                    TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Custom Painter ───────────────────────────────────────────
class _HalfDonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double total;
  final double strokeWidth;
  final double gapDegrees;
  final Color trackColor;

  _HalfDonutPainter({
    required this.values,
    required this.colors,
    required this.total,
    required this.strokeWidth,
    required this.gapDegrees,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    const totalSweep = pi;
    final gapRad = gapDegrees * pi / 180;
    final activeCount = values.where((v) => v > 0).length;
    final totalGap = gapRad * max(activeCount, 1);
    final usableSweep = totalSweep - totalGap;

    // Compensation for round caps: each cap extends by half the
    // stroke width, which in angular terms is strokeWidth / (2 * radius).
    final capAngle = strokeWidth / (2 * radius);

    if (total <= 0) return;

    // ── Segments ──
    double currentAngle = pi;

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value <= 0) continue;

      final fraction = value / total;
      final sweep = usableSweep * fraction;

      // Shrink each arc inward by the cap overshoot so
      // round ends don't eat into the gap.
      final adjustedStart = currentAngle + gapRad / 2 + capAngle;
      final adjustedSweep = (sweep - 2 * capAngle).clamp(0.01, double.infinity);

      final segmentPaint = Paint()
        ..color = i < colors.length ? colors[i] : Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        adjustedStart,
        adjustedSweep,
        false,
        segmentPaint,
      );

      currentAngle += sweep + gapRad;
    }
  }

  @override
  bool shouldRepaint(covariant _HalfDonutPainter old) => true;
}

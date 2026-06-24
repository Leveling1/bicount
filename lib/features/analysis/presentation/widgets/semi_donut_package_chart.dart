import 'dart:math';
import 'package:flutter/material.dart';

class SemiDonutChartData {
  const SemiDonutChartData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class SemiDonutChart extends StatefulWidget {
  const SemiDonutChart({
    super.key,
    required this.sections,
    required this.centerText,
    this.centerSubtitle,
    this.height = 220,
  });

  final List<SemiDonutChartData> sections;
  final String centerText;
  final String? centerSubtitle;
  final double height;

  @override
  State<SemiDonutChart> createState() => _SemiDonutChartState();
}

class _SemiDonutChartState extends State<SemiDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size(
            double.infinity,
            widget.height,
          ),
          painter: _SemiDonutPainter(
            sections: widget.sections,
            progress: Curves.easeOutCubic.transform(
              controller.value,
            ),
            centerText: widget.centerText,
            centerSubtitle: widget.centerSubtitle,
          ),
        );
      },
    );
  }
}

class _SemiDonutPainter extends CustomPainter {
  const _SemiDonutPainter({
    required this.sections,
    required this.progress,
    required this.centerText,
    required this.centerSubtitle,
  });

  final List<SemiDonutChartData> sections;
  final double progress;
  final String centerText;
  final String? centerSubtitle;

  @override
  void paint(Canvas canvas, Size size) {
    final total = sections.fold<double>(
      0,
      (p, e) => p + e.value,
    );

    if (total == 0) return;

    const gapDegree = 6;

    final strokeWidth = size.height * .16;

    final radius = min(
          size.width / 2,
          size.height,
        ) -
        strokeWidth;

    final center = Offset(
      size.width / 2,
      size.height,
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final gap = gapDegree * pi / 180;

    final availableAngle =
        pi - (sections.length - 1) * gap;

    double startAngle = pi;

    for (final section in sections) {
      final sweep =
          (section.value / total) * availableAngle;

      final animatedSweep =
          sweep * progress;

      final paint = Paint()
        ..color = section.color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle,
        animatedSweep,
        false,
        paint,
      );

      startAngle += sweep + gap;
    }

    _drawCenterText(
      canvas,
      size,
    );
  }

  void _drawCenterText(
    Canvas canvas,
    Size size,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: TextStyle(
          color: const Color(0xFF83CFFF),
          fontSize: size.height * .18,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      size.height * .55 -
          textPainter.height / 2,
    );

    textPainter.paint(
      canvas,
      textOffset,
    );

    if (centerSubtitle != null) {
      final subtitlePainter = TextPainter(
        text: TextSpan(
          text: centerSubtitle,
          style: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: size.height * .06,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      subtitlePainter.paint(
        canvas,
        Offset(
          (size.width -
                  subtitlePainter.width) /
              2,
          textOffset.dy +
              textPainter.height +
              6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _SemiDonutPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.sections != sections;
  }
}
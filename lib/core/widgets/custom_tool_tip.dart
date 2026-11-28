import 'dart:math' as math;

import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CustomToolTip extends StatefulWidget {
  const CustomToolTip({
    super.key,
    required this.text,
    required this.child,
    this.backgroundColor,
    this.textStyle,
  });

  final String text;
  final Widget child;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  @override
  State<CustomToolTip> createState() => _CustomToolTipState();
}

class _CustomToolTipState extends State<CustomToolTip> {
  final _controller = SuperTooltipController();
  static const _arrow = ArrowConfiguration();
  static const _position = PositionConfiguration();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return SuperTooltip(
      controller: _controller,
      interactionConfig: const InteractionConfiguration(showOnTap: false),
      arrowConfig: _arrow,
      positionConfig: _position,
      decorationBuilder: (target) => ShapeDecoration(
        color: widget.backgroundColor ?? theme.cardColor,
        shadows: const [
          BoxShadow(color: Colors.black26, blurRadius: AppSizes.dp20),
        ],
        shape: _TooltipBubbleBorder(
          targetX: target.dx,
          viewportWidth: viewportWidth,
          radius: AppDimens.borderRadiusLarge,
          arrowLength: _arrow.length,
          arrowWidth: _arrow.baseWidth,
        ),
      ),
      content: Text(
        widget.text,
        style: widget.textStyle ?? theme.textTheme.bodyMedium,
      ),
      child: BicountPressable(
        onTap: _controller.showTooltip,
        customBorder: const CircleBorder(),
        child: widget.child,
      ),
    );
  }
}

class _TooltipBubbleBorder extends ShapeBorder {
  const _TooltipBubbleBorder({
    required this.targetX,
    required this.viewportWidth,
    required this.radius,
    required this.arrowLength,
    required this.arrowWidth,
  });

  final double targetX;
  final double viewportWidth;
  final double radius;
  final double arrowLength;
  final double arrowWidth;

  @override
  EdgeInsetsGeometry get dimensions =>
      const EdgeInsets.all(AppDimens.paddingMedium);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final bubble = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(radius),
    ).getOuterPath(rect, textDirection: textDirection);
    if (rect.isEmpty || arrowLength <= 0 || arrowWidth <= 0) return bubble;

    // Match SuperTooltip's centering and edge clamping for a downward bubble.
    final margin = _CustomToolTipState._position.minimumOutsideMargin;
    final left = math.max(
      margin,
      math.min(targetX - rect.width / 2, viewportWidth - margin - rect.width),
    );
    final tip = rect.left + targetX - left;
    final halfArrow = math.min(arrowWidth / 2, rect.width / 2);
    final inset = math.min(radius + halfArrow, rect.width / 2);
    final base = tip.clamp(rect.left + inset, rect.right - inset).toDouble();
    final arrow = Path()
      ..moveTo(base - halfArrow, rect.top + 1)
      ..lineTo(tip, rect.top - arrowLength)
      ..lineTo(base + halfArrow, rect.top + 1)
      ..close();
    return Path.combine(PathOperation.union, bubble, arrow);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => _TooltipBubbleBorder(
    targetX: targetX,
    viewportWidth: viewportWidth,
    radius: radius * t,
    arrowLength: arrowLength * t,
    arrowWidth: arrowWidth * t,
  );
}

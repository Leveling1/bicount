import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CustomToolTip extends StatelessWidget {
  CustomToolTip({
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

  final _controller = SuperTooltipController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.showTooltip(),
      child: SuperTooltip(
        controller: _controller,
        style: TooltipStyle(
          backgroundColor: Theme.of(context).cardColor,
          borderRadius: AppDimens.borderRadiusLarge,
          bubbleDimensions: const EdgeInsets.all(AppDimens.paddingMedium),
          hasShadow: true,
          shadowColor: Colors.black26,
          shadowBlurRadius: 20.0,
        ),
        content: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        child: child,
      ),
    );
  }
}

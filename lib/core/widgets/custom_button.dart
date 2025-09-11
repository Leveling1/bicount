import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.loading,
  });
  final VoidCallback onPressed;
  final WidgetStatesController statesController = WidgetStatesController();
  final String text;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: Theme.of(context).elevatedButtonTheme.style,
        child: loading ? LoadingAnimationWidget.horizontalRotatingDots(
          color: Theme.of(context).cardColor,
          size: 50,
        ) : Text(text),
      ),
    );
  }
}

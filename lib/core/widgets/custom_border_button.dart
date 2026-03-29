import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class CustomBorderButton extends StatelessWidget {
  CustomBorderButton({
    super.key,
    required this.text,
    required this.logoPath,
    required this.onPressed,
  }) : statesController = WidgetStatesController();
  final VoidCallback onPressed;
  final WidgetStatesController statesController;
  final String text;
  final String logoPath;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppDimens.spacingSmall,
          children: [Image.asset(logoPath, width: 20, height: 20), Text(text)],
        ),
      ),
    );
  }
}

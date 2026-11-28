import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class CustomBorderButton extends StatelessWidget {
  const CustomBorderButton({
    super.key,
    required this.text,
    required this.logoPath,
    required this.onPressed,
  });
  final VoidCallback onPressed;
  final String text;
  final String logoPath;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.dp50,
      child: BicountPressable.button(
        builder: (statesController) => ElevatedButton(
          statesController: statesController,
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppDimens.spacingSmall,
            children: [
              Image.asset(
                logoPath,
                width: AppSizes.dp20,
                height: AppSizes.dp20,
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}

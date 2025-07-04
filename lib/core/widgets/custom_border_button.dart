import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class CustomBorderButton extends StatelessWidget {
  CustomBorderButton({
    super.key,
    required this.text,
    required this.logoPath,
    required this.onPressed,
  });
  VoidCallback onPressed;
  WidgetStatesController statesController = WidgetStatesController();
  final String text;
  final String logoPath;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,

        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return Theme.of(context).primaryColor;
            } else if (states.contains(WidgetState.hovered)) {
              return const Color.fromARGB(255, 208, 208, 208);
            }
            return Colors.white;
          }),
          elevation: WidgetStateProperty.resolveWith<double>((states) => 0.0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              side: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppDimens.spacingSmall,
          children: [
            Image.asset(logoPath, width: 20, height: 20),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

import 'package:bicount/core/themes/app_colors.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  CustomButton({super.key, required this.text, required this.onPressed});
  VoidCallback onPressed;
  WidgetStatesController statesController = WidgetStatesController();
  final String text;
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
              return Colors.grey[300]!; // light grey when pressed
            } else if (states.contains(WidgetState.hovered)) {
              return const Color.fromARGB(255, 208, 208, 208);
            }
            return Theme.of(context).colorScheme.surface;
          }),
          elevation: WidgetStateProperty.resolveWith<double>((states) => 0.0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            ),
          ),
        ),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

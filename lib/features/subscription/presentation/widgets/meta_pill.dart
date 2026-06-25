import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

class MetaPill extends StatelessWidget {
  const MetaPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).textTheme.bodySmall!.color!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimens.iconSizeSmall, color: foreground),
        AppDimens.spacerWidthSmall,
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              TextSpan(text: '$label: '),
              TextSpan(
                text: value,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

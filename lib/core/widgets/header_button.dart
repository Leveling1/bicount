import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class HeaderButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const HeaderButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.marginMedium),
      child: BicountPressable(
        onTap: onTap,
        color: buttonColor.withValues(alpha: 0.3),
        customBorder: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimens.borderRadiusFull),
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: AppSizes.dp70),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingSmall,
            vertical: AppDimens.paddingExtraSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.dp14, color: buttonColor),
              const SizedBox(width: AppSizes.dp6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: AppSizes.dp11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

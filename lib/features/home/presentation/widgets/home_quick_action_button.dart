import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class HomeQuickActionButton extends StatelessWidget {
  const HomeQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        hoverColor: theme.colorScheme.surfaceContainer,
        splashColor: Colors.transparent,
        highlightColor: theme.primaryColor.withValues(alpha: 0.16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimens.iconSizeLarge,
                height: AppDimens.iconSizeLarge,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: AppDimens.iconSizeSmall,
                ),
              ),
              const SizedBox(height: AppDimens.spacingSmall),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

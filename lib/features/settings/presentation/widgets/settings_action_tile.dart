import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.onTap,
    this.danger = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).textTheme.bodyLarge?.color;
    final trailingColor = danger
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).hintColor;

    return BicountPressable(
      customBorder: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppSizes.dp18),
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.dp6),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: color),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.dp6),
                  child: Text(
                    value!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (isLoading)
                LoadingAnimationWidget.hexagonDots(
                  color: Theme.of(context).primaryColor,
                  size: AppSizes.dp16,
                )
              else
                Icon(Icons.chevron_right, color: trailingColor),
            ],
          ),
        ),
      ),
    );
  }
}

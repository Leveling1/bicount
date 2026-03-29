import 'package:flutter/material.dart';

import '../../../../core/themes/app_dimens.dart';

class SubscriptionBadge extends StatelessWidget {
  const SubscriptionBadge({
    super.key,
    required this.label,
    required this.color,
  });
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingSmallMedium,
        vertical: AppDimens.paddingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}

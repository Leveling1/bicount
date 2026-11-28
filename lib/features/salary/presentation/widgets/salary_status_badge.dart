import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class SalaryStatusBadge extends StatelessWidget {
  const SalaryStatusBadge({
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
        horizontal: AppSizes.dp10,
        vertical: AppSizes.dp6,
      ),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.15),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppSizes.dp999),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

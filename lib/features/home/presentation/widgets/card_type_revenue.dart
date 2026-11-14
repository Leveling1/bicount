import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/utils/number_format_utils.dart';
import 'package:flutter/material.dart';

class CardTypeRevenue extends StatelessWidget {
  const CardTypeRevenue({
    super.key,
    required this.label,
    required this.icon,
    required this.amount,
    this.color = Colors.amber,
    required this.onTap,
    this.compact = false,
  });
  final String label;
  final Widget icon;
  final Color color;
  final double amount;
  final VoidCallback onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = Container(
      padding: AppDimens.paddingAllSmall,
      width: AppDimens.iconSizeLarge,
      height: AppDimens.iconSizeLarge,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: icon,
    );
    final values = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          NumberFormatUtils.compactCurrency(amount, compactThreshold: 100000),
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        splashColor: Colors.transparent,
        highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        onTap: onTap,
        child: compact
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingSmall,
                ),
                child: Row(
                  children: [
                    badge,
                    const SizedBox(width: AppDimens.paddingSmall),
                    Expanded(child: values),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [badge, const SizedBox(height: 5), values],
              ),
      ),
    );
  }
}

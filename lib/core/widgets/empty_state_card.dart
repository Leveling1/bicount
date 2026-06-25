import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onPressed,
    this.buttonText = "",
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.transparent, //Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.0, color: Theme.of(context).iconTheme.color),
          AppDimens.spacerMedium,
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.spacerSmall,
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.spacerMedium,
          if (onPressed != null) ...[
            SizedBox(
              height: 40,
              child: CustomButtonWithIcon(
                onPressed: onPressed!,
                text: buttonText,
                icon: Icon(Icons.add, color: Theme.of(context).cardColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyTransactionStateCard extends StatelessWidget {
  final VoidCallback? onPressed;
  const EmptyTransactionStateCard({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      icon: Icons.inbox,
      title: context.l10n.transactionEmptyState,
      message: context.l10n.transactionEmptyStateHint,
      onPressed: onPressed,
      buttonText: context.l10n.transactionEmptyStateButton,
    );
  }
}

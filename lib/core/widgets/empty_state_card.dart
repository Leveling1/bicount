import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  final VoidCallback? onPressed;
  const EmptyStateCard({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 48.0, color: Colors.grey[400]),
          AppDimens.spacerMedium,
          Text(
            'Aucune transaction enregistrée',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          AppDimens.spacerSmall,
          Text(
            'Vous pouvez ajouter une nouvelle transaction en appuyant sur le bouton ci-dessous.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppDimens.spacerMedium,
          if (onPressed != null) ...[
            SizedBox(
              height: 40,
              child: CustomButtonWithIcon(
                onPressed: onPressed!,
                text: 'Ajouter une transaction',
                icon: Icon(Icons.add, color: Theme.of(context).cardColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

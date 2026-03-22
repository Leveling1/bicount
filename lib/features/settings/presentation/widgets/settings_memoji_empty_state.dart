import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SettingsMemojiEmptyState extends StatelessWidget {
  const SettingsMemojiEmptyState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsMemojiConnectionTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          AppDimens.spacerSmall,
          Text(
            context.l10n.settingsMemojiConnectionDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          AppDimens.spacerMedium,
          CustomButton(
            text: context.l10n.commonRetry,
            loading: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_corners.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/features/whats_new/presentation/whats_new_release.dart';
import 'package:flutter/material.dart';

class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key, required this.release});

  final WhatsNewRelease release;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final entries = release.localizedEntries(l10n);

    void dismiss() => Navigator.of(context).pop(true);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) dismiss();
      },
      child: AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.dp16,
          vertical: AppSizes.dp24,
        ),
        shape: appCornerShape(
          borderRadius: BorderRadius.circular(AppDimens.radiusExtraLarge),
        ),
        title: Row(
          children: [
            Expanded(child: Text(l10n.whatsNewTitle)),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: dismiss,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimens.spacingMedium,
          children: [
            for (final entry in entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: theme.textTheme.titleSmall),
                  AppDimens.spacerSmall,
                  Text(entry.description, style: theme.textTheme.bodyMedium),
                ],
              ),
          ],
        ),
        actions: [
          CustomButton(
            text: l10n.whatsNewDismiss,
            onPressed: dismiss,
            loading: false,
          ),
        ],
      ),
    );
  }
}

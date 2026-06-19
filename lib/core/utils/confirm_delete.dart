import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

Future<void> confirmDelete(
  BuildContext context, {
  required String title,
  required String description,
  String? cta,
  String? cancel,
  required VoidCallback onConfirm,
}) async {
  await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: Theme.of(dialogContext).dialogTheme.shape,
      title: Text(title),
      content: Text(description),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(cancel ?? context.l10n.commonReject),
              ),
            ),
            AppDimens.spacerWidthMedium,
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                  onConfirm();
                },
                child: Text(cta ?? context.l10n.transactionDeleteConfirmCta),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

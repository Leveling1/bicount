import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

/// One plain-language line describing what an action will actually do, paired
/// with an icon that says at a glance whether it is safe or destructive.
class FriendConsequenceRow extends StatelessWidget {
  const FriendConsequenceRow({
    super.key,
    required this.icon,
    required this.text,
    this.tone = FriendConsequenceTone.neutral,
  });

  final IconData icon;
  final String text;
  final FriendConsequenceTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (tone) {
      FriendConsequenceTone.safe => Colors.green.shade600,
      FriendConsequenceTone.danger => theme.colorScheme.error,
      FriendConsequenceTone.neutral => theme.textTheme.bodySmall?.color,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

enum FriendConsequenceTone { safe, neutral, danger }

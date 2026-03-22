import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:flutter/material.dart';

class FriendDirectoryHeader extends StatelessWidget {
  const FriendDirectoryHeader({
    super.key,
    required this.total,
    required this.linked,
    required this.unlinked,
  });

  final int total;
  final int linked;
  final int unlinked;

  @override
  Widget build(BuildContext context) {
    return DetailsCard(
      child: Row(
        children: [
          _FriendDirectoryStat(label: context.l10n.friendsTotal, value: total),
          const SizedBox(width: AppDimens.marginMedium),
          _FriendDirectoryStat(
            label: context.l10n.friendsLinked,
            value: linked,
          ),
          const SizedBox(width: AppDimens.marginMedium),
          _FriendDirectoryStat(
            label: context.l10n.friendsToLink,
            value: unlinked,
          ),
        ],
      ),
    );
  }
}

class _FriendDirectoryStat extends StatelessWidget {
  const _FriendDirectoryStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

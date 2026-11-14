import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_feed_tile.dart';
import 'package:flutter/material.dart';

class TransactionFeedList extends StatelessWidget {
  const TransactionFeedList({
    super.key,
    required this.groups,
    required this.data,
  });

  final Map<String, List<TransactionFeedItem>> groups;
  final MainEntity data;

  @override
  Widget build(BuildContext context) {
    final entries = groups.entries.toList(growable: false);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingMedium,
        15,
        AppDimens.paddingMedium,
        50,
      ),
      sliver: SliverList.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
              AppDimens.spacerSmall,
              ...entry.value.map(
                (item) => TransactionFeedTile(item: item, data: data),
              ),
              AppDimens.spacerMedium,
            ],
          );
        },
      ),
    );
  }
}

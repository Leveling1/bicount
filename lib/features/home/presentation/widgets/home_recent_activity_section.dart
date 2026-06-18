import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/open_transaction_sheet.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/empty_state_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_feed_tile.dart';
import 'package:flutter/material.dart';

class HomeRecentActivitySection extends StatelessWidget {
  const HomeRecentActivitySection({
    super.key,
    required this.data,
    this.onShowMore,
  });

  final MainEntity data;
  final VoidCallback? onShowMore;

  @override
  Widget build(BuildContext context) {
    final recentItems = buildTransactionFeed(data).take(5).toList();

    final itemWidgets = <Widget>[];
    for (var index = 0; index < recentItems.length; index++) {
      final item = recentItems[index];
      itemWidgets.add(
        BicountReveal(
          delay: Duration(milliseconds: 210 + (index * 45)),
          child: TransactionFeedTile(item: item, data: data),
        ),
      );

      if (index < recentItems.length - 1) {
        itemWidgets.add(const SizedBox(height: AppDimens.spacingSmall));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BicountReveal(
          delay: const Duration(milliseconds: 180),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.homeTransactions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: onShowMore,
                style: Theme.of(context).textButtonTheme.style,
                child: Text(
                  context.l10n.homeShowMore,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.spacingSmall),
        if (recentItems.isEmpty)
          BicountReveal(
            delay: const Duration(milliseconds: 180),
            child: Center(
              child: EmptyStateCard(
                onPressed: () => openTransactionSheet(context, data),
              ),
            ),
          )
        else
          ...itemWidgets,
      ],
    );
  }
}

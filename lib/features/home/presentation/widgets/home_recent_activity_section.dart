import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
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
    if (recentItems.isEmpty) {
      return const SizedBox.shrink();
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppDimens.paddingExtraLarge),
            physics: const BouncingScrollPhysics(),
            itemCount: recentItems.length,
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return BicountReveal(
                delay: Duration(milliseconds: 210 + (index * 45)),
                child: TransactionFeedTile(item: item, data: data),
              );
            },
          ),
        ),
      ],
    );
  }
}

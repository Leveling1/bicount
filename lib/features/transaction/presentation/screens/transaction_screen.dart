import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_feed_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    super.key,
    required this.data,
    this.showSearchBar = false,
    required this.searchController,
    required this.selectedIndexTransaction,
  });

  final MainEntity data;
  final bool showSearchBar;
  final TextEditingController searchController;
  final int selectedIndexTransaction;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    if (!widget.showSearchBar) {
      widget.searchController.clear();
    }
    final feed = buildTransactionFeed(widget.data);
    final filteredFeed = filterTransactionFeed(
      source: feed,
      query: widget.searchController.text,
      selectedIndex: widget.selectedIndexTransaction,
    );
    final grouped = groupTransactionFeedByDate(context, filteredFeed);

    if (feed.isEmpty) {
      return Center(child: Text(context.l10n.transactionNoTransactionsFound));
    }

    return Column(
      children: [
        filteredFeed.isNotEmpty
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: ListView(
                      padding: EdgeInsets.only(top: 15, bottom: 50.h),
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...entry.value.map(
                              (item) => TransactionFeedTile(
                                item: item,
                                data: widget.data,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )
            : Expanded(
                child: Center(
                  child: Text(context.l10n.transactionNoTransactionsFound),
                ),
              ),
      ],
    );
  }
}

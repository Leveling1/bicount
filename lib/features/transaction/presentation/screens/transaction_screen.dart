import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/open_transaction_sheet.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/empty_state_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_details.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
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
    this.focusTransactionId,
  });

  final MainEntity data;
  final bool showSearchBar;
  final TextEditingController searchController;
  final int selectedIndexTransaction;
  final String? focusTransactionId;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? _openedFocusTransactionId;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant TransactionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController.removeListener(_onSearchChanged);
      widget.searchController.addListener(_onSearchChanged);
    }

    if (oldWidget.showSearchBar && !widget.showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.searchController.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _maybeOpenFocusedTransaction(List<TransactionFeedItem> feed) {
    final focusId = widget.focusTransactionId;
    if (focusId == null ||
        focusId.isEmpty ||
        _openedFocusTransactionId == focusId ||
        feed.isEmpty) {
      return;
    }

    TransactionFeedItem? match;
    for (final item in feed) {
      if (item.transaction.tid == focusId) {
        match = item;
        break;
      }
    }
    if (match == null) {
      return;
    }

    _openedFocusTransactionId = focusId;
    final resolved = match;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showTransactionFeedDetails(
        context,
        data: widget.data,
        item: resolved,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = buildTransactionFeed(widget.data);
    _maybeOpenFocusedTransaction(feed);
    final filteredFeed = filterTransactionFeed(
      data: widget.data,
      source: feed,
      query: widget.showSearchBar ? widget.searchController.text : '',
      selectedIndex: widget.selectedIndexTransaction,
    );
    final grouped = groupTransactionFeedByDate(context, filteredFeed);

    if (feed.isEmpty) {
      return BicountReveal(
        child: Center(
          child: EmptyTransactionStateCard(
            onPressed: () => openTransactionSheet(context, widget.data),
          ),
        ),
      );
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
                            AppDimens.spacerSmall,
                            ...entry.value.map(
                              (item) => TransactionFeedTile(
                                item: item,
                                data: widget.data,
                              ),
                            ),
                            AppDimens.spacerMedium,
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

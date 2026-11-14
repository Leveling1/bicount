import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/constants/backend_environment.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/features/wallet/domain/services/wallet_attribution.dart';
import 'package:bicount/features/wallet/presentation/widgets/wallet_card.dart';
import 'package:bicount/core/services/open_transaction_sheet.dart';
import 'package:bicount/core/widgets/bicount_reveal.dart';
import 'package:bicount/core/widgets/empty_state_card.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_builder.dart';
import 'package:bicount/features/transaction/presentation/helpers/transaction_feed_details.dart';
import 'package:bicount/features/transaction/presentation/models/transaction_feed_item.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_feed_list.dart';
import 'package:bicount/features/transaction/presentation/widgets/transaction_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SliverConstraints;
import 'package:go_router/go_router.dart';

part 'transaction_screen_scroll.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    super.key,
    required this.data,
    this.showSearchBar = false,
    required this.searchController,
    required this.selectedIndexTransaction,
    required this.onTransactionFilterTap,
    this.focusTransactionId,
  });

  final MainEntity data;
  final bool showSearchBar;
  final TextEditingController searchController;
  final int selectedIndexTransaction;
  final ValueChanged<int> onTransactionFilterTap;
  final String? focusTransactionId;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? _openedFocusTransactionId;
  String? _walletId;

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

    // When focusTransactionId changes (e.g., URL cleared after a sheet opened,
    // or a fresh notification tap arrives), reset the "already opened" marker
    // so the next non-null id can trigger the sheet again.
    if (oldWidget.focusTransactionId != widget.focusTransactionId) {
      _openedFocusTransactionId = null;
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _selectWallet(String? id) => setState(() => _walletId = id);

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
      // Strip the focus query so navigating away and back does not re-open
      // the sheet automatically.
      GoRouter.of(context).go('/transaction');
      showTransactionFeedDetails(context, data: widget.data, item: resolved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = buildTransactionFeed(widget.data);
    _maybeOpenFocusedTransaction(feed);
    final filteredFeed = filterTransactionFeed(
      data: widget.data,
      source: _walletId == null
          ? feed
          : feed
                .where(
                  (item) => walletSides(
                    widget.data,
                    item.transaction,
                  ).any((side) => side.id == _walletId),
                )
                .toList(),
      query: widget.showSearchBar ? widget.searchController.text : '',
      selectedIndex: widget.selectedIndexTransaction,
    );
    final grouped = groupTransactionFeedByDate(context, filteredFeed);

    return _buildScrollView(
      context,
      hasTransactions: feed.isNotEmpty,
      groups: grouped,
    );
  }
}

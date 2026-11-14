part of 'transaction_screen.dart';

extension on _TransactionScreenState {
  Widget _buildScrollView(
    BuildContext context, {
    required bool hasTransactions,
    required Map<String, List<TransactionFeedItem>> groups,
  }) {
    return CustomScrollView(
      key: const PageStorageKey<String>('transaction-feed'),
      primary: false,
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false),
      slivers: [
        if (BackendEnvironment.isLocalPreproduction)
          SliverToBoxAdapter(
            child: WalletCard(
              data: widget.data,
              walletId: _walletId,
              onChanged: _selectWallet,
            ),
          ),
        SliverLayoutBuilder(
          builder: (context, headerConstraints) => SliverMainAxisGroup(
            slivers: [
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TransactionFilterChips(
                    selectedIndex: widget.selectedIndexTransaction,
                    onTap: widget.onTransactionFilterTap,
                    filters: TransactionTypes.allTypesInt,
                  ),
                ),
              ),
              if (groups.isNotEmpty)
                TransactionFeedList(groups: groups, data: widget.data),
              SliverLayoutBuilder(
                builder: (context, constraints) => SliverToBoxAdapter(
                  child: SizedBox(
                    height: _remainingHeight(headerConstraints, constraints),
                    child: groups.isNotEmpty
                        ? null
                        : _emptyState(
                            context,
                            hasTransactions: hasTransactions,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Leave enough scroll extent to hide the cards even with a short result list.
  double _remainingHeight(SliverConstraints start, SliverConstraints end) {
    final contentHeight =
        end.precedingScrollExtent - start.precedingScrollExtent;
    return (end.viewportMainAxisExtent - contentHeight).clamp(
      0.0,
      end.viewportMainAxisExtent,
    );
  }

  Widget _emptyState(BuildContext context, {required bool hasTransactions}) {
    if (hasTransactions) {
      return Center(child: Text(context.l10n.transactionNoTransactionsFound));
    }
    return BicountReveal(
      child: Center(
        child: EmptyTransactionStateCard(
          onPressed: () => openTransactionSheet(context, widget.data),
        ),
      ),
    );
  }
}

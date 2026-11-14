part of 'transaction_screen.dart';

extension on _TransactionScreenState {
  Widget _buildScrollView(
    BuildContext context, {
    required bool hasTransactions,
    required Map<String, List<TransactionFeedItem>> groups,
  }) {
    return CustomScrollView(
      key: const PageStorageKey<String>('transaction-feed'),
      controller: _feedScrollController,
      primary: false,
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false),
      slivers: [
        if (BackendEnvironment.isLocalPreproduction)
          SliverToBoxAdapter(
            key: _walletHeaderKey,
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
              if (groups.isEmpty)
                TransactionEmptyResultsSliver(
                  precedingScrollExtent:
                      headerConstraints.precedingScrollExtent,
                  child: _emptyState(context, hasTransactions: hasTransactions),
                )
              else ...[
                TransactionFeedList(groups: groups, data: widget.data),
                SliverLayoutBuilder(
                  builder: (context, constraints) => SliverToBoxAdapter(
                    child: SizedBox(
                      height: _remainingHeight(headerConstraints, constraints),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _revealSearchResults() {
    if (!BackendEnvironment.isLocalPreproduction) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.showSearchBar ||
          !_feedScrollController.hasClients) {
        return;
      }
      final walletHeader = _walletHeaderKey.currentContext?.findRenderObject();
      if (walletHeader is! RenderSliver) return;

      final position = _feedScrollController.position;
      final headerExtent = walletHeader.geometry?.scrollExtent;
      if (headerExtent == null || !position.hasContentDimensions) return;
      final target = headerExtent.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (position.pixels >= target) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        position.jumpTo(target);
      } else {
        position.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
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
      return Text(context.l10n.transactionNoTransactionsFound);
    }
    return BicountReveal(
      child: EmptyTransactionStateCard(
        onPressed: () => openTransactionSheet(context, widget.data),
      ),
    );
  }
}

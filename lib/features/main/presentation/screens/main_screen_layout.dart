part of 'main_screen.dart';

extension _MainScreenLayout on _MainScreenState {
  Widget _buildShell(BuildContext context) {
    _scheduleInvitePresentation(GoRouterState.of(context).uri);
    final titles = localizedMainShellTitles(context);
    final currentUri = GoRouterState.of(context).uri;
    final currencyConfig = context.watch<CurrencyCubit>().state.config;
    // Registers this screen as a Theme dependent. Without it a brightness
    // change rebuilds the themed descendants but not this build method, so
    // the home widget keeps syncing the previous light/dark palette until
    // the app is restarted.
    final brightness = Theme.of(context).brightness;

    return BlocConsumer<MainBloc, MainState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final data = state is MainLoaded
            ? state.startData
            : MainEntity.fromEmpty();
        final preparedData = prepareMainScreenData(data);

        _scheduleHomeWidgetSync(
          context,
          state: state,
          data: preparedData,
          currencyConfig: currencyConfig,
          brightness: brightness,
        );
        _maybeHandlePendingWidgetAction(
          currentUri,
          state: state,
          data: preparedData,
        );

        final enableWalletSwipe =
            BackendEnvironment.isLocalPreproduction &&
            _selectedIndex == 0 &&
            state is MainLoaded;
        final shell = HomeWalletTransition(
          enabled: enableWalletSwipe,
          onSelectTab: _onItemTapped,
          builder: (openWallets) => Scaffold(
            backgroundColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.backgroundColor,
            appBar: MainShellAppBar(
              connectionState: preparedData.connectionState,
              title: titles[_selectedIndex],
              selectedIndex: _selectedIndex,
              showSearchBar: showSearchBar,
              onToggleSearch: _toggleSearch,
              onAddFunds: _openAddFundsSheet,
              onOpenSettings: () => context.push('/settings'),
              debts: preparedData.debts,
              recurringTransferts: preparedData.recurringTransferts,
            ),
            body: MainShellBody(
              selectedIndex: _selectedIndex,
              showSearchBar: showSearchBar,
              searchController: searchTransaction,
              pageController: pageController,
              lockHorizontalPaging: enableWalletSwipe,
              onPageChanged: _onPageChanged,
              screens: state is MainLoaded
                  ? _buildScreens(preparedData, openWallets)
                  : List.generate(
                      4,
                      (index) => MainLoadingSkeleton(index: index),
                    ),
            ),
            bottomNavigationBar: enableWalletSwipe
                ? null
                : CustomBottomNavigationBar(
                    selectedIndex: _selectedIndex,
                    onTap: _onItemTapped,
                  ),
            floatingActionButton: MainShellFab(
              selectedIndex: _selectedIndex,
              onPressed: () => openTransactionSheet(context, preparedData),
              transaction: preparedData.transactions.length,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        );
        if (!BackendEnvironment.isLocalPreproduction) return shell;
        return BlocProvider(
          create: (_) =>
              WalletBloc(WalletRepositoryImpl())..add(const WatchWallets()),
          child: shell,
        );
      },
    );
  }

  List<Widget> _buildScreens(MainEntity data, VoidCallback openWallets) {
    final currentUri = GoRouterState.of(context).uri;
    final focusTransactionId = currentUri.path == '/transaction'
        ? currentUri.queryParameters['tid']
        : null;
    return [
      HomeScreen(onCardTap: _goToPage, data: data, onOpenWallets: openWallets),
      const AnalysisScreen(),
      TransactionScreen(
        data: data,
        showSearchBar: showSearchBar,
        searchController: searchTransaction,
        selectedIndexTransaction: _selectedIndexTransaction,
        onTransactionFilterTap: _onItemTappedTransaction,
        focusTransactionId: focusTransactionId,
      ),
      ProfileScreen(data: data),
    ];
  }
}

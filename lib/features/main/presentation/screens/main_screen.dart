import 'package:bicount/core/constants/network_status.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_action.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_service.dart';
import 'package:bicount/core/routes/friend_invite_route.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/services/open_transaction_sheet.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/add_fund/presentation/screens/add_fund_handler.dart';
import 'package:bicount/features/analysis/presentation/screens/analysis_screen.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/home/presentation/screens/home_screen.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/main/presentation/bloc/main_bloc.dart';
import 'package:bicount/features/main/presentation/helpers/main_screen_helpers.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_app_bar.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_body.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_fab.dart';
import 'package:bicount/features/profile/presentation/screens/profile_screen.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_handler.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController pageController;
  final TextEditingController searchTransaction = TextEditingController();
  static String? _lastScheduledInviteCode;

  bool showSearchBar = false;
  late int _selectedIndex;
  int _selectedIndexTransaction = 0;
  String? _lastHandledWidgetActionToken;

  @override
  void initState() {
    super.initState();
    // Opening straight on the tab the widget action targets. The action
    // itself still waits for the data to be loaded before it runs — only the
    // starting tab changes, so the home screen is no longer shown and then
    // snapped away once loading finishes.
    _selectedIndex = _initialTabForPendingWidgetAction();
    pageController = PageController(initialPage: _selectedIndex);
    BicountHomeWidgetService.instance.addListener(_handleWidgetActionChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainBloc>().add(GetAllStartData());
    });
  }

  /// Tab the pending widget action will land on, known before the first
  /// frame: the launch URI is read while the app boots, ahead of `runApp`.
  int _initialTabForPendingWidgetAction() {
    final action = BicountHomeWidgetService.instance.pendingAction;
    if (action == null) {
      return 0;
    }

    return switch (action.type) {
      BicountHomeWidgetActionType.addTransaction ||
      BicountHomeWidgetActionType.addIncome ||
      BicountHomeWidgetActionType.addExpense ||
      BicountHomeWidgetActionType.openTransaction => 2,
      _ => 0,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUri = GoRouterState.of(context).uri;
    if (currentUri.path == '/analysis' || currentUri.path == '/graphs') {
      _goToPage(1);
    } else if (currentUri.path == '/transaction') {
      _goToPage(2);
    }
  }

  @override
  void dispose() {
    BicountHomeWidgetService.instance.removeListener(_handleWidgetActionChange);
    pageController.dispose();
    searchTransaction.dispose();
    super.dispose();
  }

  void _handleWidgetActionChange() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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

        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).bottomNavigationBarTheme.backgroundColor,
          appBar: MainShellAppBar(
            connectionState: preparedData.connectionState,
            title: titles[_selectedIndex],
            selectedIndex: _selectedIndex,
            showSearchBar: showSearchBar,
            onToggleSearch: () =>
                setState(() => showSearchBar = !showSearchBar),
            onAddFunds: _openAddFundsSheet,
            onOpenSettings: () => context.push('/settings'),
            debts: preparedData.debts,
            recurringTransferts: preparedData.recurringTransferts,
          ),
          body: MainShellBody(
            selectedIndex: _selectedIndex,
            showSearchBar: showSearchBar,
            searchController: searchTransaction,
            selectedTransactionIndex: _selectedIndexTransaction,
            onTransactionFilterTap: _onItemTappedTransaction,
            pageController: pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            screens: _buildScreens(preparedData),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
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
        );
      },
    );
  }

  void _scheduleInvitePresentation(Uri currentUri) {
    final inviteCode = FriendInviteRoute.inviteCodeFromUri(currentUri);
    if (currentUri.path != '/' || inviteCode == null) {
      return;
    }

    if (_lastScheduledInviteCode == inviteCode) {
      return;
    }

    _lastScheduledInviteCode = inviteCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/');
      context.push(FriendInviteRoute.buildSecondaryRoute(inviteCode));
    });
  }

  List<Widget> _buildScreens(MainEntity data) {
    final currentUri = GoRouterState.of(context).uri;
    final focusTransactionId = currentUri.path == '/transaction'
        ? currentUri.queryParameters['tid']
        : null;
    return [
      HomeScreen(
        onCardTap: _goToPage,
        data: data,
      ),
      const AnalysisScreen(),
      TransactionScreen(
        data: data,
        showSearchBar: showSearchBar,
        searchController: searchTransaction,
        selectedIndexTransaction: _selectedIndexTransaction,
        focusTransactionId: focusTransactionId,
      ),
      ProfileScreen(data: data),
    ];
  }

  void _onStateChanged(BuildContext context, MainState state) {
    if (state is MainLoaded) {
      return;
    }

    if (state is MainStateConnexion) {
      if (state.networkStatus == NetworkStatus.disconnected) {
        NotificationHelper.showFailureNotification(
          context,
          context.l10n.networkOfflineMessage,
        );
      } else if (state.networkStatus == NetworkStatus.unstable) {
        NotificationHelper.showFailureNotification(
          context,
          context.l10n.networkUnstableMessage,
        );
      }
    }
  }

  void _scheduleHomeWidgetSync(
    BuildContext context, {
    required MainState state,
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
    // Not read here: it only needs to be part of the call so a brightness
    // change reaches this method and re-runs the sync.
    required Brightness brightness,
  }) {
    if (state is! MainLoaded || data.user.uid.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      BicountHomeWidgetService.instance.sync(
        context: context,
        data: data,
        currencyConfig: currencyConfig,
      );
    });
  }

  void _maybeHandlePendingWidgetAction(
    Uri currentUri, {
    required MainState state,
    required MainEntity data,
  }) {
    final service = BicountHomeWidgetService.instance;
    final serviceAction = service.pendingAction;
    final uriAction = BicountHomeWidgetAction.fromShellUri(currentUri);
    final pendingAction = serviceAction ?? uriAction;
    final widgetLaunchToken = _resolveWidgetActionToken(
      currentUri,
      serviceAction: serviceAction,
      uriAction: uriAction,
      service: service,
    );

    if (pendingAction == null ||
        widgetLaunchToken == null ||
        widgetLaunchToken.isEmpty ||
        widgetLaunchToken == _lastHandledWidgetActionToken ||
        state is! MainLoaded) {
      return;
    }

    _lastHandledWidgetActionToken = widgetLaunchToken;
    service.clearPendingAction();

    // No route change before running the action. `/` and `/transaction` are
    // separate routes that each build their own MainScreen, so moving the
    // route here disposed the State owning the callback below: it woke up
    // unmounted, dropped the action, and the freshly built State had nothing
    // left to act on — the app opened on the right tab with no form. Changing
    // tab only drives the PageView, so the action runs on this State.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _performPendingWidgetAction(pendingAction, data);
    });
  }

  String? _resolveWidgetActionToken(
    Uri currentUri, {
    required BicountHomeWidgetAction? serviceAction,
    required BicountHomeWidgetAction? uriAction,
    required BicountHomeWidgetService service,
  }) {
    if (serviceAction != null) {
      final uriToken = currentUri
          .queryParameters[BicountHomeWidgetAction.launchTokenQueryParam];
      if (uriToken != null &&
          uriToken.isNotEmpty &&
          uriAction != null &&
          serviceAction.matches(uriAction)) {
        return uriToken;
      }

      return 'pending:${service.pendingActionSequence}';
    }

    return currentUri.queryParameters[BicountHomeWidgetAction
        .launchTokenQueryParam];
  }

  void _performPendingWidgetAction(
    BicountHomeWidgetAction action,
    MainEntity data,
  ) {
    switch (action.type) {
      case BicountHomeWidgetActionType.openHome:
        _onItemTapped(0);
        return;
      case BicountHomeWidgetActionType.addTransaction:
        _onItemTapped(2);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          openTransactionSheet(context, data);
        });
        return;
      case BicountHomeWidgetActionType.addIncome:
        _onItemTapped(2);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          openTransactionSheet(
            context,
            data,
            initialType: TransactionHandlerInitialType.income,
            showTypeSelector: false,
          );
        });
        return;
      case BicountHomeWidgetActionType.addExpense:
        _onItemTapped(2);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          openTransactionSheet(
            context,
            data,
            showTypeSelector: false,
          );
        });
        return;
      case BicountHomeWidgetActionType.openTransaction:
        final transactionId = action.transactionId;
        if (transactionId == null || transactionId.isEmpty) {
          _onItemTapped(2);
          return;
        }
        _onItemTapped(2);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          // TransactionScreen watches the `tid` query parameter and opens
          // that transaction's detail sheet once the feed has loaded.
          context.go(
            Uri(
              path: '/transaction',
              queryParameters: {'tid': transactionId},
            ).toString(),
          );
        });
        return;
      case BicountHomeWidgetActionType.openRecurringConfirmation:
      case BicountHomeWidgetActionType.openRecurringCharges:
      case BicountHomeWidgetActionType.openRecurringIncomes:
        final route = action.buildSecondaryRoute();
        if (route != null && !_isCurrentWidgetDestination(route)) {
          context.push(route);
        }
        return;
    }
  }

  bool _isCurrentWidgetDestination(String route) {
    final currentUri = GoRouterState.of(context).uri;
    final targetUri = Uri.parse(route);
    if (currentUri.path != targetUri.path) {
      return false;
    }

    final currentParameters =
        Map<String, String>.from(currentUri.queryParameters)
          ..remove(BicountHomeWidgetAction.homeWidgetQueryParam)
          ..remove(BicountHomeWidgetAction.launchTokenQueryParam)
          ..remove(BicountHomeWidgetAction.shellActionQueryParam);
    final targetParameters = Map<String, String>.from(
      targetUri.queryParameters,
    );
    return mapEquals(currentParameters, targetParameters);
  }

  void _onItemTappedTransaction(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _selectedIndexTransaction = index);
    });
  }

  void _onItemTapped(int index) {
    final distance = (_selectedIndex - index).abs();
    const duration = Duration(milliseconds: 380);

    if (distance == 1) {
      pageController.animateToPage(
        index,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    } else {
      pageController.jumpToPage(index);
    }

    setState(() => _selectedIndex = index);
  }

  void _goToPage(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onItemTapped(index));
  }

  void _openAddFundsSheet() {
    showCustomBottomSheet(
      context: context,
      minHeight: 0.95,
      color: null,
      child: AccountFundingHandler(),
    );
  }

  
}

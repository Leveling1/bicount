import 'package:bicount/core/constants/network_status.dart';
import 'package:bicount/core/routes/friend_invite_route.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:bicount/core/widgets/custom_bottom_sheet.dart';
import 'package:bicount/features/add_fund/presentation/screens/add_fund_handler.dart';
import 'package:bicount/features/analysis/presentation/screens/analysis_screen.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController pageController = PageController();
  final TextEditingController searchTransaction = TextEditingController();
  static String? _lastScheduledInviteCode;

  bool showSearchBar = false;
  int _selectedIndex = 0;
  int _selectedIndexTransaction = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainBloc>().add(GetAllStartData());
    });
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
    pageController.dispose();
    searchTransaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleInvitePresentation(GoRouterState.of(context).uri);
    final titles = localizedMainShellTitles(context);

    return BlocConsumer<MainBloc, MainState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final data = state is MainLoaded
            ? state.startData
            : MainEntity.fromEmpty();
        final preparedData = prepareMainScreenData(data);

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
            onPressed: () => _openTransactionSheet(preparedData),
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
    return [
      HomeScreen(onCardTap: _goToPage, data: data),
      const AnalysisScreen(),
      TransactionScreen(
        data: data,
        showSearchBar: showSearchBar,
        searchController: searchTransaction,
        selectedIndexTransaction: _selectedIndexTransaction,
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

  void _openTransactionSheet(MainEntity data) {
    showCustomBottomSheet(
      context: context,
      minHeight: 0.95,
      color: null,
      child: TransactionHandler(user: data.user, friends: data.friends),
    );
  }
}

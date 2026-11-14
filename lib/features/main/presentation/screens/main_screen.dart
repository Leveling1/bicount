import 'package:bicount/core/constants/backend_environment.dart';
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
import 'package:bicount/features/main/presentation/widgets/main_shell/home_wallet_transition.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_app_bar.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_body.dart';
import 'package:bicount/features/main/presentation/widgets/main_shell/main_shell_fab.dart';
import 'package:bicount/features/main/presentation/widgets/main_loading_skeleton.dart';
import 'package:bicount/features/profile/presentation/screens/profile_screen.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_handler.dart';
import 'package:bicount/features/transaction/presentation/screens/transaction_screen.dart';
import 'package:bicount/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bicount/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'main_screen_home_widget.dart';
part 'main_screen_layout.dart';

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
  Widget build(BuildContext context) => _buildShell(context);

  void _toggleSearch() => setState(() => showSearchBar = !showSearchBar);

  void _onPageChanged(int index) => setState(() => _selectedIndex = index);

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

  void _onItemTapped(int index, {bool animate = true}) {
    final distance = (_selectedIndex - index).abs();
    const duration = Duration(milliseconds: 380);

    if (animate && distance == 1) {
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

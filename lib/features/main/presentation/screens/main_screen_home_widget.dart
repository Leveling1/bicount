part of 'main_screen.dart';

extension _MainScreenHomeWidget on _MainScreenState {
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
          openTransactionSheet(context, data, showTypeSelector: false);
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
}

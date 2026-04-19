import 'package:bicount/core/constants/app_config.dart';

enum BicountHomeWidgetActionType {
  openHome,
  addTransaction,
  openRecurringConfirmation,
  openRecurringCharges,
  openRecurringIncomes,
}

class BicountHomeWidgetAction {
  const BicountHomeWidgetAction._({
    required this.type,
    this.recurringFundingId,
    this.expectedDate,
  });

  static const _widgetHost = 'widget';
  static const homeWidgetQueryParam = 'homeWidget';
  static const shellActionQueryParam = 'widgetAction';
  static const launchTokenQueryParam = 'widgetLaunch';

  final BicountHomeWidgetActionType type;
  final String? recurringFundingId;
  final String? expectedDate;

  String get actionKey {
    return switch (type) {
      BicountHomeWidgetActionType.openHome => 'open-home',
      BicountHomeWidgetActionType.addTransaction => 'add-transaction',
      BicountHomeWidgetActionType.openRecurringConfirmation =>
        'recurring-confirmation',
      BicountHomeWidgetActionType.openRecurringCharges => 'recurring-charges',
      BicountHomeWidgetActionType.openRecurringIncomes => 'recurring-incomes',
    };
  }

  bool get opensSecondaryPage {
    return switch (type) {
      BicountHomeWidgetActionType.openRecurringConfirmation ||
      BicountHomeWidgetActionType.openRecurringCharges ||
      BicountHomeWidgetActionType.openRecurringIncomes => true,
      _ => false,
    };
  }

  static Uri openHomeUri() => _uri('/open-home');

  static Uri addTransactionUri() => _uri('/add-transaction');

  static Uri recurringChargesUri() => _uri('/recurring-charges');

  static Uri recurringIncomesUri() => _uri('/recurring-incomes');

  static Uri recurringConfirmationUri({
    required String recurringFundingId,
    required String expectedDate,
  }) {
    return _uri(
      '/recurring-confirmation',
      queryParameters: {
        'recurringFundingId': recurringFundingId,
        'expectedDate': expectedDate,
      },
    );
  }

  static BicountHomeWidgetAction? fromUri(Uri uri) {
    if (uri.scheme != AppConfig.appScheme || uri.host != _widgetHost) {
      return null;
    }

    return _fromActionPath(
      uri.path,
      recurringFundingId: uri.queryParameters['recurringFundingId'],
      expectedDate: uri.queryParameters['expectedDate'],
    );
  }

  static BicountHomeWidgetAction? fromShellUri(Uri uri) {
    if (uri.queryParameters[homeWidgetQueryParam] != '1') {
      return null;
    }

    final actionKey = uri.queryParameters[shellActionQueryParam];
    if (actionKey == null || actionKey.isEmpty) {
      return null;
    }

    return _fromActionKey(
      actionKey,
      recurringFundingId: uri.queryParameters['recurringFundingId'],
      expectedDate: uri.queryParameters['expectedDate'],
    );
  }

  bool matches(BicountHomeWidgetAction other) {
    return type == other.type &&
        recurringFundingId == other.recurringFundingId &&
        expectedDate == other.expectedDate;
  }

  String? buildSecondaryRoute() {
    return switch (type) {
      BicountHomeWidgetActionType.openRecurringConfirmation => Uri(
        path: '/recurring-fundings',
        queryParameters: {
          if ((recurringFundingId ?? '').isNotEmpty)
            'recurringFundingId': recurringFundingId!,
          if ((expectedDate ?? '').isNotEmpty) 'expectedDate': expectedDate!,
        },
      ).toString(),
      BicountHomeWidgetActionType.openRecurringCharges => '/subscriptions',
      BicountHomeWidgetActionType.openRecurringIncomes => '/recurring-incomes',
      _ => null,
    };
  }

  String buildRoute(String launchToken) {
    return Uri(
      path: '/',
      queryParameters: {
        homeWidgetQueryParam: '1',
        launchTokenQueryParam: launchToken,
        shellActionQueryParam: actionKey,
        if ((recurringFundingId ?? '').isNotEmpty)
          'recurringFundingId': recurringFundingId!,
        if ((expectedDate ?? '').isNotEmpty) 'expectedDate': expectedDate!,
      },
    ).toString();
  }

  static BicountHomeWidgetAction? _fromActionPath(
    String path, {
    String? recurringFundingId,
    String? expectedDate,
  }) {
    return switch (path) {
      '/add-transaction' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.addTransaction,
      ),
      '/recurring-confirmation' => BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringConfirmation,
        recurringFundingId: recurringFundingId,
        expectedDate: expectedDate,
      ),
      '/recurring-charges' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringCharges,
      ),
      '/recurring-incomes' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringIncomes,
      ),
      _ => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openHome,
      ),
    };
  }

  static BicountHomeWidgetAction? _fromActionKey(
    String actionKey, {
    String? recurringFundingId,
    String? expectedDate,
  }) {
    return switch (actionKey) {
      'add-transaction' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.addTransaction,
      ),
      'recurring-confirmation' => BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringConfirmation,
        recurringFundingId: recurringFundingId,
        expectedDate: expectedDate,
      ),
      'recurring-charges' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringCharges,
      ),
      'recurring-incomes' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringIncomes,
      ),
      _ => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openHome,
      ),
    };
  }

  static Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final mergedQueryParameters = <String, String>{
      ...?queryParameters,
      homeWidgetQueryParam: '1',
    };

    return Uri(
      scheme: AppConfig.appScheme,
      host: _widgetHost,
      path: path,
      queryParameters: mergedQueryParameters,
    );
  }
}

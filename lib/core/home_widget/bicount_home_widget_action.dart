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

  final BicountHomeWidgetActionType type;
  final String? recurringFundingId;
  final String? expectedDate;

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

    return switch (uri.path) {
      '/add-transaction' => const BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.addTransaction,
      ),
      '/recurring-confirmation' => BicountHomeWidgetAction._(
        type: BicountHomeWidgetActionType.openRecurringConfirmation,
        recurringFundingId: uri.queryParameters['recurringFundingId'],
        expectedDate: uri.queryParameters['expectedDate'],
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

  String buildRoute(String launchToken) {
    return switch (type) {
      BicountHomeWidgetActionType.openHome => Uri(
        path: '/',
        queryParameters: {'widgetLaunch': launchToken},
      ).toString(),
      BicountHomeWidgetActionType.addTransaction => Uri(
        path: '/',
        queryParameters: {'widgetLaunch': launchToken},
      ).toString(),
      BicountHomeWidgetActionType.openRecurringConfirmation => Uri(
        path: '/recurring-fundings',
        queryParameters: {
          'widgetLaunch': launchToken,
          if ((recurringFundingId ?? '').isNotEmpty)
            'recurringFundingId': recurringFundingId!,
          if ((expectedDate ?? '').isNotEmpty) 'expectedDate': expectedDate!,
        },
      ).toString(),
      BicountHomeWidgetActionType.openRecurringCharges => Uri(
        path: '/subscriptions',
        queryParameters: {'widgetLaunch': launchToken},
      ).toString(),
      BicountHomeWidgetActionType.openRecurringIncomes => Uri(
        path: '/recurring-incomes',
        queryParameters: {'widgetLaunch': launchToken},
      ).toString(),
    };
  }

  static Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final mergedQueryParameters = <String, String>{
      ...?queryParameters,
      'homeWidget': '1',
    };

    return Uri(
      scheme: AppConfig.appScheme,
      host: _widgetHost,
      path: path,
      queryParameters: mergedQueryParameters,
    );
  }
}

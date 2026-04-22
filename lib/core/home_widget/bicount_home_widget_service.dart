import 'package:bicount/core/home_widget/bicount_home_widget_action.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_entry.dart';
import 'package:bicount/core/home_widget/bicount_home_widget_entry_builder.dart';
import 'package:bicount/core/routes/app_router.dart';
import 'package:bicount/features/currency/domain/entities/currency_config_entity.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BicountHomeWidgetService extends ChangeNotifier {
  BicountHomeWidgetService._();

  static final BicountHomeWidgetService instance = BicountHomeWidgetService._();
  static const _androidWidgetName = 'BicountHomeWidgetProvider';
  static const _qualifiedAndroidWidgetName =
      'com.youngsolver.bicount.BicountHomeWidgetProvider';
  static const _iOSWidgetName = 'BicountHomeWidget';
  static const _iOSAppGroupId = 'group.com.youngsolver.bicount';
  static const _entryBuilder = BicountHomeWidgetEntryBuilder();

  static const _themeKey = 'bicount_widget_theme_is_dark';
  static const _badgeKey = 'bicount_widget_badge';
  static const _titleKey = 'bicount_widget_title';
  static const _amountKey = 'bicount_widget_amount';
  static const _subtitleKey = 'bicount_widget_subtitle';
  static const _buttonLabelKey = 'bicount_widget_button_label';
  static const _mainActionUriKey = 'bicount_widget_main_action_uri';
  static const _buttonActionUriKey = 'bicount_widget_button_action_uri';
  static const _titleColorKey = 'bicount_widget_title_color';
  static const _amountColorKey = 'bicount_widget_amount_color';
  static const _subtitleColorKey = 'bicount_widget_subtitle_color';
  static const _buttonTextColorKey = 'bicount_widget_button_text_color';
  static const _duplicateLaunchWindow = Duration(milliseconds: 1200);

  BicountHomeWidgetAction? _pendingAction;
  int _pendingActionSequence = 0;
  bool _initialized = false;
  bool _retryScheduled = false;
  String? _lastSignature;
  String? _lastHandledWidgetUriSignature;
  DateTime? _lastHandledWidgetUriAt;

  BicountHomeWidgetAction? get pendingAction => _pendingAction;
  int get pendingActionSequence => _pendingActionSequence;

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_initialized || !_isSupportedPlatform) {
      return;
    }

    _initialized = true;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(_iOSAppGroupId);
      }
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      _handleWidgetUri(initialUri);
      HomeWidget.widgetClicked.listen(_handleWidgetUri);
    } catch (error, stackTrace) {
      debugPrint('BicountHomeWidgetService.initialize failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      _processPendingAction();
    });
  }

  Future<void> sync({
    required BuildContext context,
    required MainEntity data,
    required CurrencyConfigEntity currencyConfig,
  }) async {
    if (!_isSupportedPlatform) {
      return;
    }

    final entry = _entryBuilder.build(
      context: context,
      data: data,
      currencyConfig: currencyConfig,
    );
    if (entry.signature == _lastSignature) {
      return;
    }

    try {
      await _saveEntry(entry);
      _lastSignature = entry.signature;
      await _refreshWidget();
    } catch (error, stackTrace) {
      debugPrint('BicountHomeWidgetService.sync failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> resetToSignedOut() async {
    if (!_isSupportedPlatform) {
      return;
    }

    try {
      await _saveEntry(
        const BicountHomeWidgetEntry(
          isDarkTheme: false,
          badge: '',
          title: 'Open Bicount',
          amount: '',
          subtitle: 'Sign in to refresh your finance snapshot.',
          buttonLabel: 'Open app',
          mainActionUri: 'bicount://widget/open-home?homeWidget=1',
          buttonActionUri: 'bicount://widget/open-home?homeWidget=1',
          titleColor: 0xFF212121,
          amountColor: 0xFF76A646,
          subtitleColor: 0xFF757575,
          buttonTextColor: 0xFFF9F9F9,
        ),
      );
      _lastSignature = '__signed_out__';
      await _refreshWidget();
    } catch (error, stackTrace) {
      debugPrint('BicountHomeWidgetService.resetToSignedOut failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _saveEntry(BicountHomeWidgetEntry entry) async {
    await HomeWidget.saveWidgetData<bool>(_themeKey, entry.isDarkTheme);
    await HomeWidget.saveWidgetData<String>(_badgeKey, entry.badge);
    await HomeWidget.saveWidgetData<String>(_titleKey, entry.title);
    await HomeWidget.saveWidgetData<String>(_amountKey, entry.amount);
    await HomeWidget.saveWidgetData<String>(_subtitleKey, entry.subtitle);
    await HomeWidget.saveWidgetData<String>(_buttonLabelKey, entry.buttonLabel);
    await HomeWidget.saveWidgetData<String>(
      _mainActionUriKey,
      entry.mainActionUri,
    );
    await HomeWidget.saveWidgetData<String>(
      _buttonActionUriKey,
      entry.buttonActionUri,
    );
    await HomeWidget.saveWidgetData<int>(_titleColorKey, entry.titleColor);
    await HomeWidget.saveWidgetData<int>(_amountColorKey, entry.amountColor);
    await HomeWidget.saveWidgetData<int>(
      _subtitleColorKey,
      entry.subtitleColor,
    );
    await HomeWidget.saveWidgetData<int>(
      _buttonTextColorKey,
      entry.buttonTextColor,
    );
  }

  Future<void> _refreshWidget() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return HomeWidget.updateWidget(iOSName: _iOSWidgetName);
    }

    return HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      qualifiedAndroidName: _qualifiedAndroidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }

  void clearPendingAction() {
    _pendingAction = null;
  }

  void _handleWidgetUri(Uri? uri) {
    final action = uri == null ? null : BicountHomeWidgetAction.fromUri(uri);
    if (action == null) {
      return;
    }

    final signature = uri.toString();
    final handledAt = _lastHandledWidgetUriAt;
    final now = DateTime.now();
    if (_lastHandledWidgetUriSignature == signature &&
        handledAt != null &&
        now.difference(handledAt) <= _duplicateLaunchWindow) {
      return;
    }

    _lastHandledWidgetUriSignature = signature;
    _lastHandledWidgetUriAt = now;
    _pendingAction = action;
    _pendingActionSequence++;
    _processPendingAction();
  }

  void _processPendingAction() {
    final action = _pendingAction;
    if (action == null) {
      return;
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _scheduleRetry();
      return;
    }

    if (Supabase.instance.client.auth.currentSession == null) {
      final currentUri = GoRouter.of(context).state.uri;
      if (currentUri.path != '/auth' && currentUri.path != '/auth/email-code') {
        context.go('/auth');
      }
      return;
    }

    final currentUri = GoRouter.of(context).state.uri;
    if (_isShellLocation(currentUri)) {
      notifyListeners();
      return;
    }

    _restoreShellOrNavigate(context, action.buildRoute(_launchToken()));
  }

  void _restoreShellOrNavigate(BuildContext context, String route) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
      _resumePendingActionWhenShellReady(route);
      return;
    }

    context.go(route);
  }

  void _resumePendingActionWhenShellReady(
    String route, {
    int attemptsRemaining = 4,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shellContext = rootNavigatorKey.currentContext;
      if (shellContext == null) {
        if (attemptsRemaining > 0) {
          _resumePendingActionWhenShellReady(
            route,
            attemptsRemaining: attemptsRemaining - 1,
          );
        } else {
          _scheduleRetry();
        }
        return;
      }

      if (Supabase.instance.client.auth.currentSession == null) {
        return;
      }

      final activeUri = GoRouter.of(shellContext).state.uri;
      if (!_isShellLocation(activeUri)) {
        if (attemptsRemaining > 0) {
          _resumePendingActionWhenShellReady(
            route,
            attemptsRemaining: attemptsRemaining - 1,
          );
        } else {
          shellContext.go(route);
        }
        return;
      }

      notifyListeners();
    });
  }

  bool _isShellLocation(Uri uri) {
    return uri.path == '/' ||
        uri.path == '/analysis' ||
        uri.path == '/transaction';
  }

  void _scheduleRetry() {
    if (_retryScheduled) {
      return;
    }
    _retryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retryScheduled = false;
      _processPendingAction();
    });
  }

  String _launchToken() => DateTime.now().microsecondsSinceEpoch.toString();
}

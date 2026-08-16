import 'dart:convert';

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
  static const _eyebrowKey = 'bicount_widget_eyebrow';
  static const _balanceKey = 'bicount_widget_balance';
  static const _balanceColorKey = 'bicount_widget_balance_color';
  static const _mainActionUriKey = 'bicount_widget_main_action_uri';
  static const _monthDeltaLabelKey = 'bicount_widget_month_delta_label';
  static const _monthDeltaColorKey = 'bicount_widget_month_delta_color';
  static const _monthIncomeValueKey = 'bicount_widget_month_income_value';
  static const _monthIncomeLabelKey = 'bicount_widget_month_income_label';
  static const _monthExpenseValueKey = 'bicount_widget_month_expense_value';
  static const _monthExpenseLabelKey = 'bicount_widget_month_expense_label';
  static const _monthIncomeColorKey = 'bicount_widget_month_income_color';
  static const _nextItemLabelKey = 'bicount_widget_next_item_label';
  static const _nextItemAmountLabelKey =
      'bicount_widget_next_item_amount_label';
  static const _nextItemAmountColorKey =
      'bicount_widget_next_item_amount_color';
  static const _nextItemActionUriKey = 'bicount_widget_next_item_action_uri';
  static const _weekDayLabelsKey = 'bicount_widget_week_day_labels';
  static const _weekValuesKey = 'bicount_widget_week_values';
  static const _weekHighlightIndexKey = 'bicount_widget_week_highlight_index';
  static const _recentItemLabelKey = 'bicount_widget_recent_item_label';
  static const _recentItemAmountLabelKey =
      'bicount_widget_recent_item_amount_label';
  static const _recentItemAmountColorKey =
      'bicount_widget_recent_item_amount_color';
  /// Tells the native side which card to draw. Without it, "signed out" and
  /// "signed in with nothing yet" both arrive as a set of empty strings.
  static const _stateKey = 'bicount_widget_state';
  static const _singleButtonLabelKey = 'bicount_widget_single_button_label';
  static const _singleButtonActionUriKey =
      'bicount_widget_single_button_action_uri';
  static const _incomeButtonLabelKey = 'bicount_widget_income_button_label';
  static const _incomeButtonActionUriKey =
      'bicount_widget_income_button_action_uri';
  static const _expenseButtonLabelKey = 'bicount_widget_expense_button_label';
  static const _expenseButtonActionUriKey =
      'bicount_widget_expense_button_action_uri';
  static const _monthDailyIncomeKey = 'bicount_widget_month_daily_income';
  static const _monthDailyExpenseKey = 'bicount_widget_month_daily_expense';
  static const _monthCurveLabelKey = 'bicount_widget_month_curve_label';
  static const _incomeLegendLabelKey = 'bicount_widget_income_legend_label';
  static const _expenseLegendLabelKey = 'bicount_widget_expense_legend_label';
  static const _recentItemsKey = 'bicount_widget_recent_items';
  static const _monthSectionLabelKey = 'bicount_widget_month_section_label';
  static const _nextItemSectionLabelKey =
      'bicount_widget_next_item_section_label';
  static const _weekSectionLabelKey = 'bicount_widget_week_section_label';
  static const _weekSectionCompactLabelKey =
      'bicount_widget_week_section_compact_label';
  static const _entriesLabelKey = 'bicount_widget_entries_label';
  static const _exitsLabelKey = 'bicount_widget_exits_label';
  static const _titleColorKey = 'bicount_widget_title_color';
  static const _subtitleColorKey = 'bicount_widget_subtitle_color';
  static const _buttonTextColorKey = 'bicount_widget_button_text_color';
  static const _listDelimiter = '|';
  static const _duplicateLaunchWindow = Duration(milliseconds: 1200);

  BicountHomeWidgetAction? _pendingAction;
  int _pendingActionSequence = 0;
  bool _initialized = false;
  bool _retryScheduled = false;
  String? _lastSignature;
  bool _lastPublishedHadContent = false;
  String? _lastHandledWidgetUriSignature;
  DateTime? _lastHandledWidgetUriAt;

  BicountHomeWidgetAction? get pendingAction => _pendingAction;
  int get pendingActionSequence => _pendingActionSequence;

  /// Android 8+ lets an app prompt the launcher to pin the widget directly,
  /// skipping the manual "long-press home screen" flow. There is no iOS
  /// equivalent — Apple only allows the user to add widgets by hand.
  Future<bool> isPinWidgetSupported() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestPinWidget() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await HomeWidget.requestPinWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: _qualifiedAndroidWidgetName,
      );
    } catch (error, stackTrace) {
      debugPrint('BicountHomeWidgetService.requestPinWidget failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

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

    // Keep the last populated snapshot rather than flashing an empty widget
    // while the offline-first store is still hydrating.
    if (!entry.hasContent && _lastPublishedHadContent) {
      return;
    }

    try {
      await _saveEntry(entry);
      _lastSignature = entry.signature;
      _lastPublishedHadContent = entry.hasContent;
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
      // Only the state matters here: the native side draws its own signed-out
      // card from it. Sending half-filled labels is what used to leave the
      // widget with an empty balance and two unlabelled buttons.
      await _saveEntry(
        const BicountHomeWidgetEntry(
          state: BicountHomeWidgetState.signedOut,
          isDarkTheme: false,
          eyebrow: 'BICOUNT',
          balance: '',
          balanceColor: 0xFF212121,
          mainActionUri: 'bicount://widget/open-home?homeWidget=1',
          singleButtonActionUri: 'bicount://widget/open-home?homeWidget=1',
          titleColor: 0xFF212121,
          subtitleColor: 0xFF757575,
          buttonTextColor: 0xFFF9F9F9,
        ),
      );
      _lastSignature = '__signed_out__';
      // Signing out legitimately clears the widget, so the next sign-in is
      // allowed to publish an empty snapshot again.
      _lastPublishedHadContent = false;
      await _refreshWidget();
    } catch (error, stackTrace) {
      debugPrint('BicountHomeWidgetService.resetToSignedOut failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _saveEntry(BicountHomeWidgetEntry entry) async {
    await HomeWidget.saveWidgetData<String>(
      _stateKey,
      entry.state.storageValue,
    );
    await HomeWidget.saveWidgetData<bool>(_themeKey, entry.isDarkTheme);
    await HomeWidget.saveWidgetData<String>(_eyebrowKey, entry.eyebrow);
    await HomeWidget.saveWidgetData<String>(_balanceKey, entry.balance);
    await HomeWidget.saveWidgetData<int>(_balanceColorKey, entry.balanceColor);
    await HomeWidget.saveWidgetData<String>(
      _mainActionUriKey,
      entry.mainActionUri,
    );
    await HomeWidget.saveWidgetData<String>(
      _monthDeltaLabelKey,
      entry.monthDeltaLabel ?? '',
    );
    await HomeWidget.saveWidgetData<int>(
      _monthDeltaColorKey,
      entry.monthDeltaColor ?? entry.titleColor,
    );
    await HomeWidget.saveWidgetData<double>(
      _monthIncomeValueKey,
      entry.monthIncomeValue ?? 0,
    );
    await HomeWidget.saveWidgetData<String>(
      _monthIncomeLabelKey,
      entry.monthIncomeLabel ?? '',
    );
    await HomeWidget.saveWidgetData<double>(
      _monthExpenseValueKey,
      entry.monthExpenseValue ?? 0,
    );
    await HomeWidget.saveWidgetData<String>(
      _monthExpenseLabelKey,
      entry.monthExpenseLabel ?? '',
    );
    await HomeWidget.saveWidgetData<int>(
      _monthIncomeColorKey,
      entry.monthIncomeColor ?? entry.titleColor,
    );
    await HomeWidget.saveWidgetData<String>(
      _nextItemLabelKey,
      entry.nextItemLabel ?? '',
    );
    await HomeWidget.saveWidgetData<String>(
      _nextItemAmountLabelKey,
      entry.nextItemAmountLabel ?? '',
    );
    await HomeWidget.saveWidgetData<int>(
      _nextItemAmountColorKey,
      entry.nextItemAmountColor ?? entry.titleColor,
    );
    await HomeWidget.saveWidgetData<String>(
      _nextItemActionUriKey,
      entry.nextItemActionUri ?? entry.mainActionUri,
    );
    await HomeWidget.saveWidgetData<String>(
      _weekDayLabelsKey,
      entry.weekDayLabels.join(_listDelimiter),
    );
    await HomeWidget.saveWidgetData<String>(
      _weekValuesKey,
      entry.weekValues.map((value) => value.toString()).join(_listDelimiter),
    );
    await HomeWidget.saveWidgetData<int>(
      _weekHighlightIndexKey,
      entry.weekHighlightIndex ?? -1,
    );
    await HomeWidget.saveWidgetData<String>(
      _recentItemLabelKey,
      entry.recentItemLabel ?? '',
    );
    await HomeWidget.saveWidgetData<String>(
      _recentItemAmountLabelKey,
      entry.recentItemAmountLabel ?? '',
    );
    await HomeWidget.saveWidgetData<int>(
      _recentItemAmountColorKey,
      entry.recentItemAmountColor ?? entry.titleColor,
    );
    await HomeWidget.saveWidgetData<String>(
      _singleButtonLabelKey,
      entry.singleButtonLabel ?? '',
    );
    await HomeWidget.saveWidgetData<String>(
      _singleButtonActionUriKey,
      entry.singleButtonActionUri ?? entry.mainActionUri,
    );
    await HomeWidget.saveWidgetData<String>(
      _incomeButtonLabelKey,
      entry.incomeButtonLabel ?? '',
    );
    await HomeWidget.saveWidgetData<String>(
      _incomeButtonActionUriKey,
      entry.incomeButtonActionUri ?? entry.mainActionUri,
    );
    await HomeWidget.saveWidgetData<String>(
      _expenseButtonLabelKey,
      entry.expenseButtonLabel ?? '',
    );
    await HomeWidget.saveWidgetData<String>(
      _expenseButtonActionUriKey,
      entry.expenseButtonActionUri ?? entry.mainActionUri,
    );
    await HomeWidget.saveWidgetData<String>(
      _monthDailyIncomeKey,
      entry.monthDailyIncome.map((value) => value.toString()).join(
        _listDelimiter,
      ),
    );
    await HomeWidget.saveWidgetData<String>(
      _monthDailyExpenseKey,
      entry.monthDailyExpense.map((value) => value.toString()).join(
        _listDelimiter,
      ),
    );
    await HomeWidget.saveWidgetData<String>(
      _monthCurveLabelKey,
      entry.monthCurveLabel,
    );
    await HomeWidget.saveWidgetData<String>(
      _incomeLegendLabelKey,
      entry.incomeLegendLabel,
    );
    await HomeWidget.saveWidgetData<String>(
      _expenseLegendLabelKey,
      entry.expenseLegendLabel,
    );
    // JSON rather than a delimiter-joined string: transaction names are
    // free text, and SharedPreferences is XML so control-character
    // separators are not even valid there.
    await HomeWidget.saveWidgetData<String>(
      _recentItemsKey,
      jsonEncode(entry.recentItems.map((item) => item.toJson()).toList()),
    );
    await HomeWidget.saveWidgetData<String>(
      _monthSectionLabelKey,
      entry.monthSectionLabel,
    );
    await HomeWidget.saveWidgetData<String>(
      _nextItemSectionLabelKey,
      entry.nextItemSectionLabel,
    );
    await HomeWidget.saveWidgetData<String>(
      _weekSectionLabelKey,
      entry.weekSectionLabel,
    );
    await HomeWidget.saveWidgetData<String>(
      _weekSectionCompactLabelKey,
      entry.weekSectionCompactLabel,
    );
    await HomeWidget.saveWidgetData<String>(
      _entriesLabelKey,
      entry.entriesLabel,
    );
    await HomeWidget.saveWidgetData<String>(_exitsLabelKey, entry.exitsLabel);
    await HomeWidget.saveWidgetData<int>(_titleColorKey, entry.titleColor);
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

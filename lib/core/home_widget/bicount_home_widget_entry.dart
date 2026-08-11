/// Snapshot of everything a Bicount home widget layout could possibly need,
/// computed once in Dart and mirrored natively (Android RemoteViews / iOS
/// WidgetKit). Each native layout only reads the subset of fields relevant
/// to its size — this keeps the payload/theme logic in one place instead of
/// duplicating it per platform.
class BicountHomeWidgetEntry {
  const BicountHomeWidgetEntry({
    required this.isDarkTheme,
    required this.eyebrow,
    required this.balance,
    required this.balanceColor,
    required this.mainActionUri,
    this.monthDeltaLabel,
    this.monthDeltaColor,
    this.monthIncomeValue,
    this.monthIncomeLabel,
    this.monthExpenseValue,
    this.monthExpenseLabel,
    this.nextItemLabel,
    this.nextItemAmountLabel,
    this.nextItemAmountColor,
    this.nextItemActionUri,
    this.weekDayLabels = const [],
    this.weekValues = const [],
    this.weekHighlightIndex,
    this.recentItemLabel,
    this.recentItemAmountLabel,
    this.recentItemAmountColor,
    this.monthDailyIncome = const [],
    this.monthDailyExpense = const [],
    this.monthCurveLabel = '',
    this.incomeLegendLabel = '',
    this.expenseLegendLabel = '',
    this.recentItems = const [],
    this.singleButtonLabel,
    this.singleButtonActionUri,
    this.incomeButtonLabel,
    this.incomeButtonActionUri,
    this.expenseButtonLabel,
    this.expenseButtonActionUri,
    this.monthSectionLabel = '',
    this.nextItemSectionLabel = '',
    this.weekSectionLabel = '',
    this.weekSectionCompactLabel = '',
    this.entriesLabel = '',
    this.exitsLabel = '',
    required this.titleColor,
    required this.subtitleColor,
    required this.buttonTextColor,
  });

  final bool isDarkTheme;

  /// Small uppercase kicker label, e.g. "BICOUNT", "BICOUNT · SOLDE",
  /// "BICOUNT · SOLDE TOTAL".
  final String eyebrow;
  final String balance;
  final int balanceColor;

  /// Tapping the card itself (outside the buttons) opens this.
  final String mainActionUri;

  /// e.g. "+120 € ce mois". Null when there is not enough history yet.
  final String? monthDeltaLabel;
  final int? monthDeltaColor;

  /// Raw values (not formatted) so native bar heights can be computed
  /// proportionally; the *Label fields are what gets printed.
  final double? monthIncomeValue;
  final String? monthIncomeLabel;
  final double? monthExpenseValue;
  final String? monthExpenseLabel;

  /// Next upcoming item (a salary awaiting confirmation, or the closest
  /// due recurring charge/income) rendered as "Netflix — demain".
  final String? nextItemLabel;
  final String? nextItemAmountLabel;
  final int? nextItemAmountColor;
  final String? nextItemActionUri;

  /// 7-day expense bar chart (oldest to newest).
  final List<String> weekDayLabels;
  final List<double> weekValues;
  final int? weekHighlightIndex;

  final String? recentItemLabel;
  final String? recentItemAmountLabel;
  final int? recentItemAmountColor;

  /// Daily income/expense totals for the current month, day 1 → today.
  /// Drawn as two overlaid curves on the large layouts.
  final List<double> monthDailyIncome;
  final List<double> monthDailyExpense;
  final String monthCurveLabel;
  final String incomeLegendLabel;
  final String expenseLegendLabel;

  /// Most recent transactions, newest first. Large layouts show as many as
  /// their height allows, each row deep-linking to its own transaction.
  final List<BicountHomeWidgetRecentItem> recentItems;

  /// Single "+ Ajouter" CTA, used by the compact layouts.
  final String? singleButtonLabel;
  final String? singleButtonActionUri;

  /// "+ Revenu" / "- Dépense" CTA pair, used by the richer layouts.
  final String? incomeButtonLabel;
  final String? incomeButtonActionUri;
  final String? expenseButtonLabel;
  final String? expenseButtonActionUri;

  /// Static section headings. They travel with the payload rather than
  /// living in native string resources because the app has its own
  /// in-app language picker, which can differ from the device locale.
  final String monthSectionLabel;
  final String nextItemSectionLabel;
  final String weekSectionLabel;
  final String weekSectionCompactLabel;
  final String entriesLabel;
  final String exitsLabel;

  final int titleColor;
  final int subtitleColor;
  final int buttonTextColor;

  /// Whether this snapshot carries real account activity. Offline-first
  /// loading emits a `MainLoaded` with an empty entity before the local
  /// rows arrive, and publishing that would blank an already-populated
  /// widget until the app is next opened.
  bool get hasContent =>
      recentItems.isNotEmpty ||
      (monthIncomeValue ?? 0) != 0 ||
      (monthExpenseValue ?? 0) != 0;

  String get signature => [
    isDarkTheme,
    eyebrow,
    balance,
    balanceColor,
    mainActionUri,
    monthDeltaLabel,
    monthDeltaColor,
    monthIncomeValue,
    monthIncomeLabel,
    monthExpenseValue,
    monthExpenseLabel,
    nextItemLabel,
    nextItemAmountLabel,
    nextItemAmountColor,
    nextItemActionUri,
    weekDayLabels.join(','),
    weekValues.join(','),
    weekHighlightIndex,
    recentItemLabel,
    recentItemAmountLabel,
    recentItemAmountColor,
    monthDailyIncome.join(','),
    monthDailyExpense.join(','),
    monthCurveLabel,
    incomeLegendLabel,
    expenseLegendLabel,
    recentItems.map((item) => item.signature).join(','),
    singleButtonLabel,
    singleButtonActionUri,
    incomeButtonLabel,
    incomeButtonActionUri,
    expenseButtonLabel,
    expenseButtonActionUri,
    monthSectionLabel,
    nextItemSectionLabel,
    weekSectionLabel,
    weekSectionCompactLabel,
    entriesLabel,
    exitsLabel,
    titleColor,
    subtitleColor,
    buttonTextColor,
  ].join('|');
}

/// One row of the recent-transactions list shown on the large layouts.
class BicountHomeWidgetRecentItem {
  const BicountHomeWidgetRecentItem({
    required this.label,
    required this.amountLabel,
    required this.amountColor,
    required this.actionUri,
  });

  final String label;
  final String amountLabel;
  final int amountColor;

  /// Deep link opening this exact transaction in the app.
  final String actionUri;

  Map<String, dynamic> toJson() => {
    'label': label,
    'amount': amountLabel,
    'color': amountColor,
    'uri': actionUri,
  };

  String get signature => '$label~$amountLabel~$amountColor~$actionUri';
}

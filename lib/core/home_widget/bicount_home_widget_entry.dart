class BicountHomeWidgetEntry {
  const BicountHomeWidgetEntry({
    required this.isDarkTheme,
    required this.badge,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.buttonLabel,
    required this.mainActionUri,
    required this.buttonActionUri,
    required this.titleColor,
    required this.amountColor,
    required this.subtitleColor,
    required this.buttonTextColor,
  });

  final bool isDarkTheme;
  final String badge;
  final String title;
  final String amount;
  final String subtitle;
  final String buttonLabel;
  final String mainActionUri;
  final String buttonActionUri;
  final int titleColor;
  final int amountColor;
  final int subtitleColor;
  final int buttonTextColor;

  String get signature => [
    isDarkTheme,
    badge,
    title,
    amount,
    subtitle,
    buttonLabel,
    mainActionUri,
    buttonActionUri,
    titleColor,
    amountColor,
    subtitleColor,
    buttonTextColor,
  ].join('|');
}

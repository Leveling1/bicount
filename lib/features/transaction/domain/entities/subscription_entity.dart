class SubscriptionEntity {
  final String title;
  final double amount;
  final String currency;
  final int frequency; // monthly, weekly, yearly, custom
  final int? customIntervalDays; // only used for custom frequency

  final String startDate;
  final String nextBillingDate;

  final String? note;
  final int status; // active, paused, cancelled

  final String createdAt;

  SubscriptionEntity({
    required this.title,
    required this.amount,
    required this.currency,
    required this.frequency,
    this.customIntervalDays,
    required this.startDate,
    required this.nextBillingDate,
    this.note,
    required this.status,
    required this.createdAt,
  });
}

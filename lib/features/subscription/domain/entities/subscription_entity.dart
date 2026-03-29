class SubscriptionEntity {
  final String title;
  final double amount;
  final String currency;
  final int frequency;
  final String startDate;
  final String nextBillingDate;
  final String? note;
  final int status;
  final int category;
  final String? sid;
  final String createdAt;

  SubscriptionEntity({
    required this.title,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.startDate,
    required this.nextBillingDate,
    this.note,
    required this.status,
    required this.createdAt,
    this.category = 0,
    this.sid,
  });
}

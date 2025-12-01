class AddAccountFundingEntity {
  final String source;
  final String? note;
  final double amount;
  final String currency;
  final String date;

  AddAccountFundingEntity({
    required this.source,
    required this.amount,
    required this.currency,
    this.note,
    required this.date,
  });
}
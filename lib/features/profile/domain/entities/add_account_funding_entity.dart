class AddAccountFundingEntity {
  final String source;
  final String? note;
  final double amount;
  final String currency;

  AddAccountFundingEntity({
    required this.source,
    required this.amount,
    required this.currency,
    this.note,
  });
}
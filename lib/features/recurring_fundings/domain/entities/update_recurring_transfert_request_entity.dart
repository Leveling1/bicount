class UpdateRecurringTransfertRequestEntity {
  const UpdateRecurringTransfertRequestEntity({
    required this.recurringTransfertId,
    required this.title,
    required this.note,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.startDate,
  });

  final String recurringTransfertId;
  final String title;
  final String note;
  final double amount;
  final String currency;
  final int frequency;
  final String startDate;
}

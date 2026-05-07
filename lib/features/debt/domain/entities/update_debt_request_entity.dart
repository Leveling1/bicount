class UpdateDebtRequestEntity {
  const UpdateDebtRequestEntity({
    required this.debtId,
    required this.title,
    required this.note,
    required this.principalDate,
    required this.principalAmount,
    required this.currency,
    required this.dueDate,
    required this.expectedRepaymentAmount,
  });

  final String debtId;
  final String title;
  final String note;
  final String principalDate;
  final double principalAmount;
  final String currency;
  final String dueDate;
  final double expectedRepaymentAmount;
}

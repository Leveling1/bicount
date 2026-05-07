class RecordDebtPaymentRequestEntity {
  const RecordDebtPaymentRequestEntity({
    required this.debtId,
    required this.amount,
  });

  final String debtId;
  final double amount;
}

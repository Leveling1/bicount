class RecordDebtPaymentRequestEntity {
  const RecordDebtPaymentRequestEntity({
    required this.debtId,
    required this.amount,
    required this.currency,
  });

  final String debtId;
  final double amount;
  final String currency;
}

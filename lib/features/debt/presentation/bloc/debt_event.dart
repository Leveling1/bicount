part of 'debt_bloc.dart';

sealed class DebtEvent {
  const DebtEvent();
}

final class RecordDebtPaymentRequested extends DebtEvent {
  const RecordDebtPaymentRequested(this.request);

  final RecordDebtPaymentRequestEntity request;
}

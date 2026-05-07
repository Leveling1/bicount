part of 'debt_bloc.dart';

sealed class DebtEvent {
  const DebtEvent();
}

final class UpdateDebtRequested extends DebtEvent {
  const UpdateDebtRequested(this.request);

  final UpdateDebtRequestEntity request;
}

final class DeleteDebtRequested extends DebtEvent {
  const DeleteDebtRequested(this.debtId);

  final String debtId;
}

final class RecordDebtPaymentRequested extends DebtEvent {
  const RecordDebtPaymentRequested(this.request);

  final RecordDebtPaymentRequestEntity request;
}

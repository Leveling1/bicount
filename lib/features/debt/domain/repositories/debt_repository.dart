import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';

abstract class DebtRepository {
  Future<void> createDebt(DebtModel debt);
  Future<void> deleteDebt(String debtId);
  Future<void> recordDebtPayment(RecordDebtPaymentRequestEntity request);
}

import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

abstract class DebtRepository {
  Future<void> createDebt(DebtModel debt);
  Future<void> deleteDebt(String debtId);
  Future<DebtModel?> findDebtById(String debtId);
  Future<DebtModel?> findDebtByPrincipalTransactionId(
    String principalTransactionId,
  );
  Future<void> recordDebtPayment(RecordDebtPaymentRequestEntity request);
  Future<void> updateDebtContract(UpdateDebtRequestEntity request);
  Future<void> deleteDebtContract(String debtId);
  Future<void> deleteDebtLinkedTransaction(TransactionEntity transaction);
}

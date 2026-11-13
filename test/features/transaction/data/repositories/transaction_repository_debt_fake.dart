part of 'transaction_repository_impl_test_support.dart';

class FakeDebtRepository implements DebtRepository {
  FakeDebtRepository({this.principalDebt});

  DebtModel? principalDebt;
  UpdateDebtRequestEntity? updatedDebtRequest;
  String? deletedDebtId;
  TransactionEntity? deletedDebtLinkedTransaction;

  @override
  Future<void> createDebt(DebtModel debt) async {}

  @override
  Future<void> deleteDebt(String debtId) async {
    deletedDebtId = debtId;
  }

  @override
  Future<void> deleteDebtContract(String debtId) async {
    deletedDebtId = debtId;
  }

  @override
  Future<void> deleteDebtLinkedTransaction(
    TransactionEntity transaction,
  ) async {
    deletedDebtLinkedTransaction = transaction;
  }

  @override
  Future<DebtModel?> findDebtById(String debtId) async {
    if (principalDebt?.debtId == debtId) {
      return principalDebt;
    }
    return null;
  }

  @override
  Future<DebtModel?> findDebtByPrincipalTransactionId(
    String principalTransactionId,
  ) async {
    if (principalDebt?.principalTransactionId == principalTransactionId) {
      return principalDebt;
    }
    return null;
  }

  @override
  Future<void> recordDebtPayment(
    RecordDebtPaymentRequestEntity request,
  ) async {}

  @override
  Future<void> updateDebtContract(UpdateDebtRequestEntity request) async {
    updatedDebtRequest = request;
  }
}

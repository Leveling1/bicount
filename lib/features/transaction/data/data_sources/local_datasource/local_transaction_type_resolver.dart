import 'package:bicount/core/constants/transaction_types.dart';

int resolveLocalTransactionType({
  required String ownerId,
  required String senderId,
  required String beneficiaryId,
}) {
  if (senderId == ownerId) {
    return TransactionTypes.expenseCode;
  }
  if (beneficiaryId == ownerId) {
    return TransactionTypes.incomeCode;
  }
  return TransactionTypes.othersCode;
}

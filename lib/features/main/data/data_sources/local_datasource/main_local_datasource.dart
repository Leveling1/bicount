import '../../../../transaction/data/models/transaction.model.dart';

abstract class MainLocalDataSource {
  Stream<List<TransactionModel>> getTransaction();
}

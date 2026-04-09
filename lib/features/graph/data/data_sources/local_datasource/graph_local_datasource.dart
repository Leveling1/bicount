import 'package:bicount/features/transaction/data/models/transaction.model.dart';

abstract class GraphLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();
}

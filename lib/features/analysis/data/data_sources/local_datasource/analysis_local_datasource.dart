import 'package:bicount/features/transaction/data/models/transaction.model.dart';

abstract class AnalysisLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();
}

import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class GraphSourceData {
  const GraphSourceData({required this.transactions});

  final List<TransactionModel> transactions;
}

import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

import '../../../authentification/domain/entities/user.dart';
import '../../data/models/transaction.model.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(Map<String, dynamic> transaction);
}

import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

import '../../../../subscription/data/models/subscription.model.dart';

abstract class GraphLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();
  Stream<List<SubscriptionModel>> watchSubscriptions();
  Stream<List<AccountFundingModel>> watchAccountFundings();
}

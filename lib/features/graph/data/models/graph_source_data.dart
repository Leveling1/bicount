import 'package:bicount/features/profile/data/models/account_funding.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class GraphSourceData {
  const GraphSourceData({
    required this.transactions,
    required this.subscriptions,
    required this.fundings,
  });

  final List<TransactionModel> transactions;
  final List<SubscriptionModel> subscriptions;
  final List<AccountFundingModel> fundings;
}

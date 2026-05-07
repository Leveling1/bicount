import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class AnalysisSourceData {
  const AnalysisSourceData({
    required this.transactions,
    required this.debts,
    required this.recurringTransferts,
    this.currentUserId,
    this.friends = const [],
  });

  final List<TransactionModel> transactions;
  final List<DebtModel> debts;
  final List<RecurringTransfertModel> recurringTransferts;
  final String? currentUserId;
  final List<FriendsModel> friends;
}

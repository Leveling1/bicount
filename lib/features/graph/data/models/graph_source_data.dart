import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';

class GraphSourceData {
  const GraphSourceData({
    required this.transactions,
    this.currentUserId,
    this.friends = const [],
  });

  final List<TransactionModel> transactions;
  final String? currentUserId;
  final List<FriendsModel> friends;
}

import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

import '../../../main/data/models/friends.model.dart';

class TransactionDetailArgs {
  final TransactionEntity transaction;
  final List<FriendsModel> friends;

  TransactionDetailArgs({
    required this.transaction,
    required this.friends,
  });
}

import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

import '../../../main/data/models/friends.model.dart';

class TransactionDetailArgs {
  final TransactionEntity transactionDetail;
  final List<FriendsModel> friends;

  TransactionDetailArgs({
    required this.transactionDetail,
    required this.friends,
  });
}

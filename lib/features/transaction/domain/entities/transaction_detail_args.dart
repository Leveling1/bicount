import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';

import '../../../main/data/models/friends.model.dart';

class TransactionDetailArgs {
  final UserModel user;
  final TransactionEntity transactionDetail;
  final List<FriendsModel> friends;

  TransactionDetailArgs({
    required this.user,
    required this.transactionDetail,
    required this.friends,
  });
}

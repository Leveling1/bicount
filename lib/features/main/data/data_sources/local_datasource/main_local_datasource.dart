import 'package:bicount/features/authentification/data/models/user.model.dart';

import '../../../../transaction/data/models/transaction.model.dart';
import '../../models/friends.model.dart';

abstract class MainLocalDataSource {
  Stream<List<TransactionModel>> getTransaction();
  Stream<UserModel> getUserDetails();
  Stream<List<FriendsModel>> getFriends();
}

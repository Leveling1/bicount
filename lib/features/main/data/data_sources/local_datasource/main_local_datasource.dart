import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';

import '../../../../transaction/data/models/transaction.model.dart';
import '../../models/friends.model.dart';

abstract class MainLocalDataSource {
  Stream<UserModel> getUserDetails();
  Stream<List<FriendsModel>> getFriends();
  Stream<List<SubscriptionModel>> getSubscriptions();
  Stream<List<TransactionModel>> getTransaction();
}

import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';

import '../../../../transaction/data/models/transaction.model.dart';
import '../../models/friends.model.dart';

abstract class MainLocalDataSource {
  Stream<UserModel> getUserDetails();
  Stream<List<FriendsModel>> getFriends();
  Stream<List<TransactionModel>> getTransaction();
  Stream<List<RecurringTransfertModel>> getRecurringTransferts();
  Future<void> forceHydrate();
}

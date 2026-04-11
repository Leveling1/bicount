import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transaction_repository_impl_test_support.dart';

void main() {
  test(
    'recurring transaction creates one placeholder friend and reuses it for the template and ledger row',
    () async {
      final localDataSource = FakeTransactionLocalDataSource();
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringExpenseRequest(
          draftParty(username: 'Netflix', relationType: FriendConst.friend),
        ),
      );

      expect(localDataSource.createFriendCallCount, 1);
      expect(localDataSource.savedTransactions, hasLength(1));
      expect(savedRecurringTransfert, isNotNull);
      expect(
        savedRecurringTransfert?.beneficiaryId,
        localDataSource.createdFriends.single.sid,
      );
      expect(
        localDataSource.savedTransactions.single.beneficiaryId,
        localDataSource.createdFriends.single.sid,
      );
      expect(
        localDataSource.createdFriends.single.relationType,
        FriendConst.subscription,
      );
      expect(localDataSource.savedTransactions.single.generationMode, 1);
    },
  );

  test(
    'recurring transaction reuses an existing matching placeholder friend instead of creating a duplicate',
    () async {
      final existingFriend = FriendsModel(
        sid: 'existing-subscription',
        uid: null,
        fid: 'owner-1',
        username: 'Netflix',
        image: '',
        email: '',
        relationType: FriendConst.subscription,
      );
      final localDataSource = FakeTransactionLocalDataSource(
        matchingFriend: existingFriend,
      );
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringExpenseRequest(
          draftParty(username: 'Netflix', relationType: FriendConst.friend),
        ),
      );

      expect(localDataSource.findMatchingFriendCallCount, 1);
      expect(localDataSource.createFriendCallCount, 0);
      expect(savedRecurringTransfert?.beneficiaryId, existingFriend.sid);
      expect(
        localDataSource.savedTransactions.single.beneficiaryId,
        existingFriend.sid,
      );
    },
  );
}

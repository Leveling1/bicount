import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/recurring_fundings/data/models/recurring_transfert.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTransactionLocalDataSource implements TransactionLocalDataSource {
  _FakeTransactionLocalDataSource({this.matchingFriend});

  FriendsModel? matchingFriend;
  int createFriendCallCount = 0;
  int findMatchingFriendCallCount = 0;
  final List<FriendsModel> createdFriends = [];
  final List<_SavedTransactionRecord> savedTransactions = [];

  @override
  Future<Either<Failure, FriendsModel>> createANewFriend(
    FriendsModel friend,
  ) async {
    createFriendCallCount += 1;
    final createdFriend = FriendsModel(
      sid: 'created-$createFriendCallCount',
      uid: null,
      fid: 'owner-1',
      username: friend.username,
      email: friend.email,
      image: friend.image,
      give: 0,
      receive: 0,
      relationType: friend.relationType,
    );
    createdFriends.add(createdFriend);
    return Right(createdFriend);
  }

  @override
  Future<Either<Failure, FriendsModel?>> findMatchingFriend(
    FriendsModel friend,
  ) async {
    findMatchingFriendCallCount += 1;
    return Right(matchingFriend);
  }

  @override
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
    String? recurringTransfertId,
    int? generationMode,
  }) async {
    savedTransactions.add(
      _SavedTransactionRecord(
        title: title,
        senderId: senderId,
        beneficiaryId: beneficiaryId,
        recurringTransfertId: recurringTransfertId,
        generationMode: generationMode,
      ),
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity previousTransaction, {
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    required String beneficiaryId,
    required String image,
  }) async {
    return const Right(null);
  }
}

class _SavedTransactionRecord {
  const _SavedTransactionRecord({
    required this.title,
    required this.senderId,
    required this.beneficiaryId,
    required this.recurringTransfertId,
    required this.generationMode,
  });

  final String title;
  final String senderId;
  final String beneficiaryId;
  final String? recurringTransfertId;
  final int? generationMode;
}

void main() {
  FriendsModel currentUser() {
    return FriendsModel(
      sid: 'user-1',
      uid: 'user-1',
      username: 'Louis',
      image: '',
      email: 'louis@example.com',
      relationType: FriendConst.friend,
    );
  }

  FriendsModel draftParty({
    required String username,
    required int relationType,
  }) {
    return FriendsModel(
      sid: '',
      uid: '',
      username: username,
      image: '',
      email: '',
      relationType: relationType,
    );
  }

  CreateTransactionRequestEntity recurringExpenseRequest(FriendsModel party) {
    return CreateTransactionRequestEntity(
      name: 'Subscription payment',
      date: DateTime(2026, 4, 11).toIso8601String(),
      totalAmount: 19.99,
      currency: 'USD',
      sender: currentUser(),
      note: '',
      splitMode: TransactionSplitMode.equal,
      splits: [TransactionSplitInputEntity(beneficiary: party)],
      isRecurring: true,
      recurringFrequency: 1,
      recurringTypeId: TransactionTypes.subscriptionCode,
    );
  }

  test(
    'recurring transaction creates one placeholder friend and reuses it for the template and ledger row',
    () async {
      final localDataSource = _FakeTransactionLocalDataSource();
      RecurringTransfertModel? savedRecurringTransfert;
      final repository = TransactionRepositoryImpl(
        localDataSource,
        saveRecurringTransfert: (recurringTransfert) async {
          savedRecurringTransfert = recurringTransfert;
        },
      );

      await repository.createTransaction(
        recurringExpenseRequest(
          draftParty(
            username: 'Netflix',
            relationType: FriendConst.subscription,
          ),
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
      final localDataSource = _FakeTransactionLocalDataSource(
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
          draftParty(
            username: 'Netflix',
            relationType: FriendConst.subscription,
          ),
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

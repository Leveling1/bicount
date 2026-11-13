import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/constants/state_app.dart';
import 'package:bicount/core/constants/transaction_types.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/debt/data/models/debt.model.dart';
import 'package:bicount/features/debt/domain/entities/record_debt_payment_request_entity.dart';
import 'package:bicount/features/debt/domain/entities/update_debt_request_entity.dart';
import 'package:bicount/features/debt/domain/repositories/debt_repository.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';

part 'transaction_repository_fixtures.dart';
part 'transaction_repository_debt_fake.dart';

class FakeTransactionLocalDataSource implements TransactionLocalDataSource {
  FakeTransactionLocalDataSource({this.matchingFriend});

  FriendsModel? matchingFriend;
  int createFriendCallCount = 0;
  int findMatchingFriendCallCount = 0;
  final List<FriendsModel> createdFriends = [];
  final List<SavedTransactionRecord> savedTransactions = [];
  UpdatedTransactionRecord? updatedTransaction;

  @override
  Future<Either<Failure, FriendsModel>> createANewFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
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
      relationType: FriendConst.getTypeOfFriend(transactionType),
    );
    createdFriends.add(createdFriend);
    return Right(createdFriend);
  }

  @override
  Future<Either<Failure, FriendsModel?>> findMatchingFriend(
    FriendsModel friend, {
    required int transactionType,
  }) async {
    findMatchingFriendCallCount += 1;
    return Right(matchingFriend);
  }

  @override
  Future<Either<Failure, void>> saveTransaction(
    String gtid, {
    String? transactionId,
    required String title,
    required String date,
    required double amount,
    required int category,
    required String currency,
    required String note,
    required String senderId,
    String? senderWalletId,
    String? beneficiaryWalletId,
    required String beneficiaryId,
    required String image,
    required int type,
    String? originId,
    String? originOccurrenceDate,
    int? generationMode,
  }) async {
    savedTransactions.add(
      SavedTransactionRecord(
        title: title,
        senderId: senderId,
        beneficiaryId: beneficiaryId,
        type: type,
        originId: originId,
        originOccurrenceDate: originOccurrenceDate,
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
    String? senderWalletId,
    String? beneficiaryWalletId,
    required String beneficiaryId,
    required String image,
    required int type,
    int? frequency,
    String? originId,
    String? originOccurrenceDate,
    int? generationMode,
  }) async {
    updatedTransaction = UpdatedTransactionRecord(
      previousTransaction: previousTransaction,
      title: title,
      date: date,
      amount: amount,
      category: category,
      currency: currency,
      note: note,
      senderId: senderId,
      beneficiaryId: beneficiaryId,
      image: image,
      type: type,
      frequency: frequency,
      originId: originId,
      originOccurrenceDate: originOccurrenceDate,
      generationMode: generationMode,
    );
    return const Right(null);
  }
}

class SavedTransactionRecord {
  const SavedTransactionRecord({
    required this.title,
    required this.senderId,
    required this.beneficiaryId,
    required this.type,
    required this.originId,
    required this.originOccurrenceDate,
    required this.generationMode,
  });

  final String title;
  final String senderId;
  final String beneficiaryId;
  final int type;
  final String? originId;
  final String? originOccurrenceDate;
  final int? generationMode;
}

class UpdatedTransactionRecord {
  const UpdatedTransactionRecord({
    required this.previousTransaction,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.currency,
    required this.note,
    required this.senderId,
    required this.beneficiaryId,
    required this.image,
    required this.type,
    required this.frequency,
    required this.originId,
    required this.originOccurrenceDate,
    required this.generationMode,
  });

  final TransactionEntity previousTransaction;
  final String title;
  final String date;
  final double amount;
  final int category;
  final String currency;
  final String note;
  final String senderId;
  final String beneficiaryId;
  final String image;
  final int type;
  final int? frequency;
  final String? originId;
  final String? originOccurrenceDate;
  final int? generationMode;
}

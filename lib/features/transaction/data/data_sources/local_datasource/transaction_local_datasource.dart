import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';

abstract class TransactionLocalDataSource {
  Future<Either<Failure, FriendsModel>> createANewFriend (FriendsModel friend);
  Future<Either<Failure, void>> saveTransaction(
    Map<String, dynamic> transaction,
    String gtid,
    String senderId,
    String beneficiaryId,
    String image,
  );
}

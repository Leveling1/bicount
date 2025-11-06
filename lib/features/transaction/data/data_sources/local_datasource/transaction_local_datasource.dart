import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../authentification/data/models/user.model.dart';

abstract class TransactionLocalDataSource {
  Future<Either<Failure, UserModel>> createANewFriend (FriendsModel friend);
  Future<Either<Failure, void>> createANewLink (UserModel friend);
  Future<Either<Failure, void>> saveTransaction(
    Map<String, dynamic> transaction,
    String gtid,
    String senderId,
    String beneficiaryId
  );
}

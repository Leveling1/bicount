import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../../../main/data/models/friends.model.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<void> createTransaction(Map<String, dynamic> transaction) async {
    try {
      final List<FriendsModel> beneficiaryList = transaction['beneficiaryList'];
      final sender = transaction['sender'];
      final gtid = Uuid().v4();

      String senderId = sender.sid;

      // 1. Créer l'expéditeur SI nécessaire et obtenir son ID
      if (senderId.isEmpty) {
        final Either<Failure, FriendsModel> senderResult = await localDataSource
            .createANewFriend(sender);

        senderId = await senderResult.fold(
          (failure) async {
            throw failure;
          },
          (userModel) async {
            //await Future.delayed(Duration(milliseconds: 100));
            return userModel.sid;
          },
        );
      }

      // 2. Traiter chaque bénéficiaire
      for (final friend in beneficiaryList) {
        String beneficiaryId = friend.sid;

        if (beneficiaryId.isEmpty) {
          final Either<Failure, FriendsModel> friendResult =
              await localDataSource.createANewFriend(friend);

          beneficiaryId = await friendResult.fold(
            (failure) async {
              throw failure;
            },
            (friend) async {
              return friend.sid;
            },
          );
        }

        // 3. Sauvegarder la transaction
        final Either<Failure, void> saveResult = await localDataSource
            .saveTransaction(transaction, gtid, senderId, beneficiaryId);

        await saveResult.fold((failure) => throw failure, (_) => null);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure();
    }
  }
}

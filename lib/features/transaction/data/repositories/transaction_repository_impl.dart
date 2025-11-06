import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/data/models/user.model.dart';
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
        final Either<Failure, UserModel> senderResult = await localDataSource.createANewFriend(sender);

        senderId = await senderResult.fold(
              (failure) async {
            throw failure;
          },
              (userModel) async {
            // Attendre que l'utilisateur soit bien créé en base
            await Future.delayed(Duration(milliseconds: 100)); // Petite pause pour la synchronisation
            return userModel.sid;
          },
        );

        // Créer le lien seulement après vérification
        final Either<Failure, void> linkResult = await localDataSource.createANewLink(sender);
        await linkResult.fold(
              (failure) => throw failure,
              (_) => null,
        );
      }

      // 2. Traiter chaque bénéficiaire
      for (final friend in beneficiaryList) {
        String beneficiaryId = friend.sid;
        late UserModel beneficiary;

        if (beneficiaryId.isEmpty) {
          final Either<Failure, UserModel> friendResult = await localDataSource.createANewFriend(friend);

          beneficiaryId = await friendResult.fold(
                (failure) async {
              throw failure;
            },
                (userModel) async {
              await Future.delayed(Duration(milliseconds: 100));
              beneficiary = userModel;
              return userModel.sid;
            },
          );

          // Créer le lien seulement après vérification
          final Either<Failure, void> linkResult = await localDataSource.createANewLink(beneficiary);
          await linkResult.fold(
                (failure) => throw failure,
                (_) => null,
          );
        }

        // 3. Sauvegarder la transaction
        final Either<Failure, void> saveResult = await localDataSource.saveTransaction(
            transaction, gtid, senderId, beneficiaryId
        );

        await saveResult.fold(
              (failure) => throw failure,
              (_) => null,
        );
      }
    } on Failure catch (e) {
      throw e;
    } catch (e) {
      throw UnknownFailure();
    }
  }
}

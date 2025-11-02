import 'package:bicount/features/transaction/data/data_sources/local_datasource/transaction_local_datasource.dart';
import 'package:dartz/dartz.dart';

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

      // Traiter chaque bénéficiaire séquentiellement
      for (final friend in beneficiaryList) {
        String beneficiaryId = friend.sid;

        // Si l'ID est vide, créer un nouvel ami
        if (beneficiaryId.isEmpty) {
          final Either<Failure, UserModel> friendResult = await localDataSource.createANewFriend(friend);

          // Gérer le résultat avec fold au lieu de if/else
          await friendResult.fold(
                (failure) async {
              throw failure; // Propager l'erreur
            },
                (userModel) async {
              beneficiaryId = userModel.sid;

              // Créer le lien après la création de l'ami
              final Either<Failure, void> linkResult = await localDataSource.createANewLink(userModel);

              // Gérer le résultat du lien
              linkResult.fold(
                    (failure) => throw failure,
                    (_) {}, // Succès - ne rien faire
              );
            },
          );
        }

        // Sauvegarder la transaction avec l'ID du bénéficiaire
        final Either<Failure, void> saveResult = await localDataSource.saveTransaction(transaction, beneficiaryId);

        // Gérer le résultat de la sauvegarde
        saveResult.fold(
              (failure) => throw failure,
              (_) {}, // Succès - ne rien faire
        );
      }
    } on Failure catch (e) {
      // Relancer les erreurs métier
      throw e;
    } catch (e) {
      // Capturer les autres erreurs
      throw UnknownFailure();
    }
  }
}

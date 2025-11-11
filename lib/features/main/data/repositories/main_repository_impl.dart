import 'dart:async';

import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentification/data/models/user.model.dart';
import '../../../transaction/data/models/transaction.model.dart';
import '../../domain/repositories/main_repository.dart';
import '../data_sources/local_datasource/main_local_datasource.dart';

class MainRepositoryImpl implements MainRepository {
  final MainLocalDataSource localDataSource;
  MainRepositoryImpl(this.localDataSource);

  @override
  Stream<MainEntity> getStartDataStream() {
    try {
      Stream<UserModel> userStream = localDataSource.getUserDetails();
      Stream<List<FriendsModel>> userLinkStream = localDataSource.getFriends();
      Stream<List<TransactionModel>> transactionStream = localDataSource.getTransaction();
      // Abonnement au flux temps réel des utilisateurs
      return Rx.combineLatest3<UserModel, List<FriendsModel>, List<TransactionModel>, MainEntity>(
        userStream,
        userLinkStream,
        transactionStream,
        (UserModel user, List<FriendsModel> usersLink, List<TransactionModel> transactions) {
          return _convertToEntity(
            user,
            usersLink,
            transactions
          );
        },
      ).handleError((error, stackTrace) {
        throw MessageFailure(message: "Erreur de combinaison des données: ${error.toString()}");
      });
    } catch (e) {
      // En cas d’erreur, on renvoie un flux d’erreur
      return Stream.error(MessageFailure(message: e.toString()));
    }
  }

  MainEntity _convertToEntity(
      UserModel user,
      List<FriendsModel> friends,
      List<TransactionModel> transactions,
      ) {
    return MainEntity(
      user: user,
      friends: friends,
      transactions: transactions
    );
  }
}

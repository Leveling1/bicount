import 'dart:async';

import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_core/core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../authentification/data/models/user.model.dart';
import '../../models/friends.model.dart';

class LocalMainDataSourceImpl implements MainLocalDataSource{
  final supabase = Supabase.instance.client;
  String get uid => supabase.auth.currentUser!.id;

  /// For the own information
  final Map<String, BehaviorSubject<UserModel>> _userDetailsCache = {};
  final Map<String, StreamSubscription<List<UserModel>>> _userDetailsSubscriptions = {};
  @override
  Stream<UserModel> getUserDetails() {
    try {
      // Si déjà en cache, retourner le stream existant
      if (_userDetailsCache.containsKey(uid)) {
        return _userDetailsCache[uid]!.stream;
      }

      // Créer un nouveau BehaviorSubject pour cette entreprise
      final companyDetailsController = BehaviorSubject<UserModel>();
      _userDetailsCache[uid] = companyDetailsController;

      // CORRECTION: Le type de subscription est StreamSubscription<List<CompanyModel>>
      final StreamSubscription<List<UserModel>> subscription =
      Repository().subscribeToRealtime<UserModel>(
          query: Query(where: [Where.exact('sid', uid)])
      ).listen((List<UserModel> companies) { // Spécifier le type List<CompanyModel>
        if (companies.isNotEmpty) {
          // Prendre le premier élément de la liste
          companyDetailsController.add(companies.first);
        } else {
          companyDetailsController.addError(
              MessageFailure(message: "Entreprise non trouvée")
          );
        }
      }, onError: (error) {
        companyDetailsController.addError(error);
      });

      _userDetailsSubscriptions[uid] = subscription;

      return companyDetailsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des détails: ${e.toString()}"),
      );
    }
  }

  /// For the List of linked user
  final Map<String, BehaviorSubject<List<FriendsModel>>> _userLinkCache = {};
  final Map<String, StreamSubscription<List<FriendsModel>>> _userLinkSubscriptions = {};
  @override
  Stream<List<FriendsModel>> getFriends() {
    try {
      if (_userLinkCache.containsKey(uid)) {
        return _userLinkCache[uid]!.stream;
      }
      final friendsController = BehaviorSubject<List<FriendsModel>>.seeded([]);
      _userLinkCache[uid] = friendsController;

      final StreamSubscription<List<FriendsModel>> subscription =
      Repository().subscribeToRealtime<FriendsModel>().listen(
      (List<FriendsModel> projects) {
        friendsController.add(projects);
      }, onError: (error) {
        friendsController.addError(error);
      });

      _userLinkSubscriptions[uid] = subscription;

      return friendsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des projets: ${e.toString()}"),
      );
    }
  }

  /// For the List of transaction
  final Map<String, BehaviorSubject<List<TransactionModel>>> _transactionCache = {};
  final Map<String, StreamSubscription<List<TransactionModel>>> _transactionSubscriptions = {};
  @override
  Stream<List<TransactionModel>> getTransaction() {
    try {
      if (_transactionCache.containsKey(uid)) {
        return _transactionCache[uid]!.stream;
      }
      final transactionsController = BehaviorSubject<List<TransactionModel>>.seeded([]);
      _transactionCache[uid] = transactionsController;

      final StreamSubscription<List<TransactionModel>> subscription =
      Repository().subscribeToRealtime<TransactionModel>(
          query: Query(where: [Where.exact('senderId', uid)])
      ).listen((List<TransactionModel> transactions) {
        transactionsController.add(transactions);
      }, onError: (error) {
        transactionsController.addError(error);
      });

      _transactionSubscriptions[uid] = subscription;

      return transactionsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des projets: ${e.toString()}"),
      );
    }
  }


}
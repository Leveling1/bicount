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
  @override
  Stream<UserModel> getUserDetails() {
    try {

      // Create a new BehaviorSubject for this user
      final userDetailsController = BehaviorSubject<UserModel>();

      // CORRECTION: The subscription type is StreamSubscription<List<UserModel>>
      Repository().subscribeToRealtime<UserModel>(
          query: Query(where: [Where.exact('sid', uid)])
      ).listen((List<UserModel> companies) { // Specify the type List<UserModel>
        if (companies.isNotEmpty) {
          // Take the first element of the list
          userDetailsController.add(companies.first);
        } else {
          userDetailsController.addError(
              MessageFailure(message: "User not found")
          );
        }
      }, onError: (error) {
        userDetailsController.addError(error);
      });

      return userDetailsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Error fetching details: ${e.toString()}"),
      );
    }
  }

  /// For the List of linked user
  @override
  Stream<List<FriendsModel>> getFriends() {
    try {
      final friendsController = BehaviorSubject<List<FriendsModel>>.seeded([]);

      Repository().subscribeToRealtime<FriendsModel>().listen(
      (List<FriendsModel> projects) {
        friendsController.add(projects);
      }, onError: (error) {
        friendsController.addError(error);
      });

      return friendsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Error fetching friends: ${e.toString()}"),
      );
    }
  }

  /// For the List of transaction
  @override
  Stream<List<TransactionModel>> getTransaction() {
    try {
      final transactionsController = BehaviorSubject<List<TransactionModel>>.seeded([]);

      Repository().subscribeToRealtime<TransactionModel>()
        .listen((List<TransactionModel> transactions) {
        transactionsController.add(transactions);
      }, onError: (error) {
        transactionsController.addError(error);
      });

      return transactionsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Error fetching transactions: ${e.toString()}"),
      );
    }
  }
}
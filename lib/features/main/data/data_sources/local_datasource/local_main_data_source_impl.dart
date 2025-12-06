import 'dart:async';

import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/subscription.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../authentification/data/models/user.model.dart';
import '../../models/friends.model.dart';

class LocalMainDataSourceImpl implements MainLocalDataSource {
  /// For the own information
  @override
  Stream<UserModel> getUserDetails() {
    try {
      // Create a new BehaviorSubject for this user
      final userDetailsController = BehaviorSubject<UserModel>();

      // CORRECTION: The subscription type is StreamSubscription<List<UserModel>>
      Repository().subscribeToRealtime<UserModel>().listen(
        (List<UserModel> users) {
          if (users.isNotEmpty) {
            // Take the first element of the list
            userDetailsController.add(users.first);
          } else {
            userDetailsController.addError(
              MessageFailure(message: "User not found"),
            );
          }
        },
        onError: (error) {
          userDetailsController.addError(error);
        },
      );

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
        (List<FriendsModel> friends) {
          friendsController.add(friends);
        },
        onError: (error) {
          friendsController.addError(error);
        },
      );

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
      final transactionsController =
          BehaviorSubject<List<TransactionModel>>.seeded([]);

      Repository().subscribeToRealtime<TransactionModel>().listen(
        (List<TransactionModel> transactions) {
          transactionsController.add(transactions);
        },
        onError: (error) {
          transactionsController.addError(error);
        },
      );

      return transactionsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Error fetching transactions: ${e.toString()}"),
      );
    }
  }

  /// For the List of subscription
  @override
  Stream<List<SubscriptionModel>> getSubscriptions() {
    try {
      final subscriptionsController =
          BehaviorSubject<List<SubscriptionModel>>.seeded([]);

      Repository().subscribeToRealtime<SubscriptionModel>().listen(
        (List<SubscriptionModel> subscriptions) {
          subscriptionsController.add(subscriptions);
        },
        onError: (error) {
          subscriptionsController.addError(error);
        },
      );

      return subscriptionsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Error fetching subscriptions: ${e.toString()}"),
      );
    }
  }
}

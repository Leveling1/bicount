import 'dart:async';

import 'package:bicount/brick/repository.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:brick_core/query.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_local_hydration.dart';

class LocalMainDataSourceImpl implements MainLocalDataSource {
  LocalMainDataSourceImpl() {
    _activeUserId = supabaseInstance.auth.currentUser?.id;
    _authSubscription = supabaseInstance.auth.onAuthStateChange.listen((state) {
      final nextUserId = state.session?.user.id;
      if (nextUserId != _activeUserId) {
        _activeUserId = nextUserId;
        _resetCaches();
      }
    });
  }

  final supabaseInstance = Supabase.instance.client;

  String? _activeUserId;
  StreamSubscription<dynamic>? _authSubscription;

  BehaviorSubject<UserModel>? _userSubject;
  StreamSubscription<List<UserModel>>? _userSubscription;

  BehaviorSubject<List<FriendsModel>>? _friendsSubject;
  StreamSubscription<List<FriendsModel>>? _friendsSubscription;

  BehaviorSubject<List<TransactionModel>>? _transactionsSubject;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;

  BehaviorSubject<List<SubscriptionModel>>? _subscriptionsSubject;
  StreamSubscription<List<SubscriptionModel>>? _subscriptionsSubscription;

  BehaviorSubject<List<AccountFundingModel>>? _accountFundingsSubject;
  StreamSubscription<List<AccountFundingModel>>? _accountFundingsSubscription;

  String get uid => supabaseInstance.auth.currentUser!.id;

  @override
  Stream<UserModel> getUserDetails() {
    final existing = _userSubject;
    if (existing != null) {
      return existing.stream;
    }

    try {
      final subject = BehaviorSubject<UserModel>();
      _userSubject = subject;
      final query = Query(where: [Where.exact('uid', uid)]);

      unawaited(primeUserSubject(subject, query));
      _userSubscription = Repository()
          .subscribeToRealtime<UserModel>(query: query)
          .listen((users) {
            if (users.isEmpty) {
              return;
            }
            subject.add(users.first);
          }, onError: subject.addError);

      return subject.stream;
    } catch (error) {
      return Stream.error(
        MessageFailure(message: 'Error fetching user details: $error'),
      );
    }
  }

  @override
  Stream<List<FriendsModel>> getFriends() {
    return _cachedListStream<FriendsModel>(
      getSubject: () => _friendsSubject,
      setSubject: (subject) => _friendsSubject = subject,
      getSubscription: () => _friendsSubscription,
      setSubscription: (subscription) => _friendsSubscription = subscription,
      errorLabel: 'friends',
      query: Query(where: [Where.exact('fid', uid)]),
    );
  }

  @override
  Stream<List<TransactionModel>> getTransaction() {
    return _cachedListStream<TransactionModel>(
      getSubject: () => _transactionsSubject,
      setSubject: (subject) => _transactionsSubject = subject,
      getSubscription: () => _transactionsSubscription,
      setSubscription: (subscription) =>
          _transactionsSubscription = subscription,
      errorLabel: 'transactions',
      query: Query(where: [Where.exact('uid', uid)]),
    );
  }

  @override
  Stream<List<SubscriptionModel>> getSubscriptions() {
    return _cachedListStream<SubscriptionModel>(
      getSubject: () => _subscriptionsSubject,
      setSubject: (subject) => _subscriptionsSubject = subject,
      getSubscription: () => _subscriptionsSubscription,
      setSubscription: (subscription) =>
          _subscriptionsSubscription = subscription,
      errorLabel: 'subscriptions',
      query: Query(where: [Where.exact('sid', uid)]),
    );
  }

  @override
  Stream<List<AccountFundingModel>> getAccountFundings() {
    return _cachedListStream<AccountFundingModel>(
      getSubject: () => _accountFundingsSubject,
      setSubject: (subject) => _accountFundingsSubject = subject,
      getSubscription: () => _accountFundingsSubscription,
      setSubscription: (subscription) =>
          _accountFundingsSubscription = subscription,
      errorLabel: 'account fundings',
      query: Query(where: [Where.exact('sid', uid)]),
    );
  }

  Stream<List<T>> _cachedListStream<T extends OfflineFirstWithSupabaseModel>({
    required BehaviorSubject<List<T>>? Function() getSubject,
    required void Function(BehaviorSubject<List<T>> subject) setSubject,
    required StreamSubscription<List<T>>? Function() getSubscription,
    required void Function(StreamSubscription<List<T>> subscription)
    setSubscription,
    required String errorLabel,
    Query? query,
  }) {
    final existing = getSubject();
    if (existing != null) {
      return existing.stream;
    }

    try {
      final subject = BehaviorSubject<List<T>>.seeded(const []);
      setSubject(subject);

      unawaited(primeListSubject(subject, query));
      final subscription = Repository()
          .subscribeToRealtime<T>(query: query)
          .listen(subject.add, onError: subject.addError);
      setSubscription(subscription);
      return subject.stream;
    } catch (error) {
      return Stream.error(
        MessageFailure(message: 'Error fetching $errorLabel: $error'),
      );
    }
  }

  void _resetCaches() {
    _userSubscription?.cancel();
    _friendsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _subscriptionsSubscription?.cancel();
    _accountFundingsSubscription?.cancel();

    _userSubject?.close();
    _friendsSubject?.close();
    _transactionsSubject?.close();
    _subscriptionsSubject?.close();
    _accountFundingsSubject?.close();

    _userSubscription = null;
    _friendsSubscription = null;
    _transactionsSubscription = null;
    _subscriptionsSubscription = null;
    _accountFundingsSubscription = null;

    _userSubject = null;
    _friendsSubject = null;
    _transactionsSubject = null;
    _subscriptionsSubject = null;
    _accountFundingsSubject = null;
  }

  void dispose() {
    _authSubscription?.cancel();
    _resetCaches();
  }
}

import 'dart:async';

import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/main/domain/entities/main_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:brick_core/core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../brick/repository.dart';
import '../../../../core/errors/failure.dart';
import '../../../authentification/data/models/user.model.dart';
import '../../../transaction/data/models/transaction.model.dart';
import '../../domain/repositories/main_repository.dart';
import '../data_sources/local_datasource/main_local_datasource.dart';

class MainRepositoryImpl implements MainRepository {
  final Connectivity _connectivity = Connectivity();
  final MainLocalDataSource localDataSource;
  final InternetConnectionChecker _checker = InternetConnectionChecker();

  final StreamController<NetworkStatus> _controller =
  StreamController<NetworkStatus>.broadcast();

  Timer? _stabilityTimer;
  int _unstableCounter = 0;
  NetworkStatus _currentStatus = NetworkStatus.connected;
  StreamSubscription? _connectivitySubscription;

  MainRepositoryImpl(this.localDataSource) {
    _initializeNetworkMonitoring();
  }

  void _initializeNetworkMonitoring() {
    _checkInitialNetworkStatus();

    // Correction pour la nouvelle API connectivity_plus qui retourne List<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Gérer plusieurs résultats de connectivité
      _handleConnectivityResults(results);
    });

    _stabilityTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkNetworkStability());
  }

  Future<void> _checkInitialNetworkStatus() async {
    try {
      final hasInternet = await _checker.hasConnection;

      // La nouvelle API retourne une List<ConnectivityResult>
      final connectivityResults = await _connectivity.checkConnectivity();

      NetworkStatus status = _determineNetworkStatus(connectivityResults, hasInternet);

      _currentStatus = status;
      _controller.add(status);
    } catch (e) {
      print('Erreur lors de la vérification initiale du réseau: $e');
      _currentStatus = NetworkStatus.disconnected;
      _controller.add(NetworkStatus.disconnected);
    }
  }

  void _handleConnectivityResults(List<ConnectivityResult> results) async {
    try {
      final hasInternet = await _checker.hasConnection;

      NetworkStatus newStatus = _determineNetworkStatus(results, hasInternet);

      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _controller.add(newStatus);

        // Reset counter when status changes
        if (newStatus == NetworkStatus.connected || newStatus == NetworkStatus.disconnected) {
          _unstableCounter = 0;
        }
      }
    } catch (e) {
      print('Erreur lors du traitement du changement de connectivité: $e');
    }
  }

  NetworkStatus _determineNetworkStatus(List<ConnectivityResult> results, bool hasInternet) {
    // Si pas d'internet ou aucune connectivité
    if (!hasInternet || results.isEmpty || results.every((result) => result == ConnectivityResult.none)) {
      return NetworkStatus.disconnected;
    }

    // Si on a une connexion Wi-Fi ou mobile
    if (results.any((result) => result == ConnectivityResult.wifi || result == ConnectivityResult.mobile)) {
      return NetworkStatus.connected;
    }

    // Autres cas (ethernet, bluetooth, etc.)
    if (results.any((result) => result != ConnectivityResult.none)) {
      return NetworkStatus.connected;
    }

    return NetworkStatus.disconnected;
  }

  Future<void> _checkNetworkStability() async {
    try {
      final hasInternet = await _checker.hasConnection;

      if (!hasInternet) {
        _unstableCounter++;
        // Si on a des déconnexions répétées, considérer comme instable
        if (_unstableCounter >= 2 && _currentStatus != NetworkStatus.unstable) {
          _currentStatus = NetworkStatus.unstable;
          _controller.add(NetworkStatus.unstable);
        }
      } else {
        // Si on retrouve la connexion, revenir à connecté
        if (_currentStatus != NetworkStatus.connected) {
          _unstableCounter = 0;
          _currentStatus = NetworkStatus.connected;
          _controller.add(NetworkStatus.connected);
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification de la stabilité: $e');
    }
  }

  @override
  Stream<NetworkStatus> get networkStatus => _controller.stream;

  void dispose() {
    _stabilityTimer?.cancel();
    _connectivitySubscription?.cancel();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

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

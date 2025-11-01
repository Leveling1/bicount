import 'dart:async';

import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/home/data/data_sources/local_datasource/home_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_core/core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';

class LocalHomeDataSourceImpl implements HomeLocalDataSource {
  final supabase = Supabase.instance.client;
  String get uid => supabase.auth.currentUser!.id;


  /// For the own data
  final Map<String, BehaviorSubject<UserModel>> _ownDetailsCache = {};
  final Map<String, StreamSubscription<List<UserModel>>> _ownDetailsSubscriptions = {};
  @override
  Stream<UserModel> getOwnData() {
    try {
      if (_ownDetailsCache.containsKey(uid)) {
        return _ownDetailsCache[uid]!.stream;
      }

      final companyDetailsController = BehaviorSubject<UserModel>();
      _ownDetailsCache[uid] = companyDetailsController;

      final StreamSubscription<List<UserModel>> subscription =
      Repository().subscribeToRealtime<UserModel>(
          query: Query(where: [Where.exact('uid', uid)])
      ).listen((List<UserModel> companies) {
        if (companies.isNotEmpty) {
          companyDetailsController.add(companies.first);
        } else {
          companyDetailsController.addError(
              MessageFailure(message: "Donnée introuvable.")
          );
        }
      }, onError: (error) {
        companyDetailsController.addError(error);
      });

      _ownDetailsSubscriptions[uid] = subscription;

      return companyDetailsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des détails: ${e.toString()}"),
      );
    }
  }
  void disposeOwnDetails() {
    _ownDetailsSubscriptions[uid]?.cancel();
    _ownDetailsSubscriptions.remove(uid);
    _ownDetailsCache[uid]?.close();
    _ownDetailsCache.remove(uid);
  }
  void close() {
    // Nettoyer les abonnements aux détails
    for (final subscription in _ownDetailsSubscriptions.values) {
      subscription.cancel();
    }
    _ownDetailsSubscriptions.clear();

    for (final controller in _ownDetailsCache.values) {
      controller.close();
    }
    _ownDetailsCache.clear();
  }
}
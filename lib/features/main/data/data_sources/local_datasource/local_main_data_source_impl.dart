import 'dart:async';

import 'package:bicount/features/main/data/data_sources/local_datasource/main_local_datasource.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:brick_core/core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';

class LocalMainDataSourceImpl implements MainLocalDataSource{

  final supabase = Supabase.instance.client;
  String get uid => supabase.auth.currentUser!.id;

  final Map<String, BehaviorSubject<List<TransactionModel>>> _transactionCache = {};
  final Map<String, StreamSubscription<List<TransactionModel>>> _transactionSubscriptions = {};
  @override
  Stream<List<TransactionModel>> getTransaction() {
    try {
      if (_transactionCache.containsKey(uid)) {
        return _transactionCache[uid]!.stream;
      }
      final projectsController = BehaviorSubject<List<TransactionModel>>.seeded([]);
      _transactionCache[uid] = projectsController;

      final StreamSubscription<List<TransactionModel>> subscription =
      Repository().subscribeToRealtime<TransactionModel>(
          query: Query(
              where: [
                WherePhrase([
                  Where('beneficiary_id').isExactly(uid),
                  Where('sender_id').isExactly(uid),
                ], isRequired: false)
              ]
          )
      ).listen((List<TransactionModel> projects) {
        projectsController.add(projects);
      }, onError: (error) {
        projectsController.addError(error);
      });

      _transactionSubscriptions[uid] = subscription;

      return projectsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des projets: ${e.toString()}"),
      );
    }
  }


}
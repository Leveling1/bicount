import 'dart:async';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/home/domain/entities/home.dart';
import 'package:bicount/features/transaction/data/models/transaction.model.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/errors/failure.dart';
import '../data_sources/local_datasource/home_local_datasource.dart';
import '../data_sources/remote_datasource/home_remote_datasource.dart';
import '/features/home/domain/repositories/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  HomeRepositoryImpl(this.remoteDataSource, this.localDataSource);

  final supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final StreamController<UserModel> _controller = StreamController<UserModel>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String get uid => supabase.auth.currentUser!.id;
  String? get accessToken => supabase.auth.currentSession?.accessToken;

  @override
  Stream<HomeEntity> getDataStream() { // Correction du type de retour
    try {
      // Récupérer les deux streams
      Stream<UserModel> ownDataStream = localDataSource.getOwnData();

      // Combiner les deux streams en un seul
      return Rx.combineLatest<UserModel, HomeEntity>(
        [ownDataStream],
        (value) {
          final ownData = value[0];
          return _convertToEntity(ownData);
        },
      ).handleError((error) {
        throw MessageFailure(message: "Erreur de combinaison des données: ${error.toString()}");
      });
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des détails: ${e.toString()}"),
      );
    }
  }

// CORRECTION: La méthode prend seulement 2 paramètres maintenant
  HomeEntity _convertToEntity(
      UserModel model
  ) {
    return HomeEntity(
      ownData: model,
    );
  }

}

import 'dart:async';

import 'package:bicount/features/authentification/data/models/user_model.dart';

import '/core/errors/failure.dart';
import '/features/home/domain/repositories/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl();
  final supabaseInstance = Supabase.instance.client;
  String get uid => supabaseInstance.auth.currentUser!.id;
  String? get accessToken => supabaseInstance.auth.currentSession?.accessToken;
  RealtimeChannel? _channel;
  final StreamController<UserModel> _controller = StreamController<UserModel>.broadcast();

  @override
  Stream<UserModel> getDataStream() {
    // 1. Récupérer les données initiales
    _loadInitialData();

    // 2. S'abonner aux changements
    _subscribeToChanges();

    return _controller.stream;
  }

  Future<void> _loadInitialData() async {
    try {
      final res = await supabaseInstance
          .from('users')
          .select('*')
          .eq('uuid', uid)
          .single();

      final UserModel currentData = UserModel.fromJson(res);
      _controller.add(currentData);
    } catch (e) {
      print('Erreur lors du chargement initial: $e');
      _controller.addError(e);
    }
  }

  void _subscribeToChanges() {
    _channel = supabaseInstance.channel('users-$uid')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'users',
      filter: PostgresChangeFilter(
        column: 'uuid',
        value: uid,
        type: PostgresChangeFilterType.eq,
      ),
      callback: (payload) async {
        try {
          print('Changement détecté: ${payload.eventType}');

          // Utiliser directement les nouvelles données du payload si possible
          if (payload.newRecord != null) {
            final UserModel updatedData = UserModel.fromJson(payload.newRecord!);
            _controller.add(updatedData);
          } else {
            // Fallback: récupérer depuis la DB
            final res = await supabaseInstance
                .from('users')
                .select('*')
                .eq('uuid', uid)
                .single();

            final UserModel currentData = UserModel.fromJson(res);
            _controller.add(currentData);
          }
        } catch (e) {
          print('Erreur dans le callback: $e');
          _controller.addError(e);
        }
      },
    ).subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('Abonnement réussi au canal users-$uid');
      } else if (status == RealtimeSubscribeStatus.channelError) {
        print('Erreur d\'abonnement: $error');
        _controller.addError(error ?? 'Erreur d\'abonnement');
      }
    });
  }

// N'oubliez pas de nettoyer les ressources
  void dispose() {
    _channel?.unsubscribe();
    _controller.close();
  }
}

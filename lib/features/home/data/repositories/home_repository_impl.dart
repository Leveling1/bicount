import 'dart:async';
import 'package:bicount/features/authentification/data/models/user_model.dart';
import '/features/home/domain/repositories/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl();

  final supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final StreamController<UserModel> _controller = StreamController<UserModel>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String get uid => supabase.auth.currentUser!.id;
  String? get accessToken => supabase.auth.currentSession?.accessToken;

  @override
  Stream<UserModel> getDataStream() {
    _loadInitialData();
    _subscribeToChanges();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((statuses) {
      final status = statuses.isNotEmpty ? statuses.first : ConnectivityResult.none;

      if (status == ConnectivityResult.none) {
        _controller.addError("No internet connection");
      } else {
        _reloadData();
      }
    });


    return _controller.stream;
  }

  /// Charge les données utilisateur actuelles
  Future<void> _loadInitialData() async {
    try {
      final user = await _fetchUser();
      _controller.add(user);
    } catch (e) {
      _handleError(e);
    }
  }

  /// Recharge les données + resouscrit au canal
  Future<void> _reloadData() async {
    await _loadInitialData();
    _subscribeToChanges();
  }

  /// Récupération depuis Supabase
  Future<UserModel> _fetchUser() async {
    final res = await supabase
        .from('users')
        .select('*')
        .eq('uuid', uid)
        .single();
    return UserModel.fromJson(res);
  }

  void _subscribeToChanges() {
    // Nettoyer l’ancienne souscription avant d’en créer une nouvelle
    _channel?.unsubscribe();

    _channel = supabase.channel('users-$uid').onPostgresChanges(
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
          _controller.add(UserModel.fromJson(payload.newRecord));
        } catch (e) {
          _handleError(e);
        }
      },
    ).subscribe((status, [error]) {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          break;
        case RealtimeSubscribeStatus.channelError:
          _controller.addError(error ?? "Subscription error");
          break;
        case RealtimeSubscribeStatus.closed:
          _controller.addError("No internet connection");
          break;
        case RealtimeSubscribeStatus.timedOut:
          _controller.addError("Subscription timed out");
          break;
      }
    });
  }

  void _handleError(Object e) {
    final message = e.toString().contains("SocketException")
        ? "No internet connection"
        : "Loading error: $e";
    _controller.addError(message);
  }

  void dispose() {
    _channel?.unsubscribe();
    _connectivitySub?.cancel();
    _controller.close();
  }
}

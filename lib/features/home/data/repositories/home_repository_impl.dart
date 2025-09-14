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
  final _controller = StreamController<UserModel>.broadcast();

  @override
  Stream<UserModel> getDataStream() {
    supabaseInstance.channel('users')
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
          final res = await supabaseInstance
              .from('users')
              .select('*')
              .eq('uuid', uid)
              .single();

          final UserModel currentData = UserModel.fromJson(res);

          _controller.add(currentData);
        } catch (e) {
          _controller.addError(e);
        }
      },
    )
        .subscribe();

    return _controller.stream;
  }
}

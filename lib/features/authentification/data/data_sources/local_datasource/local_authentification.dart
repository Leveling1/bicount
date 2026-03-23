import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/features/authentification/data/data_sources/local_datasource/authentification_local_datasource.dart';
import 'package:brick_core/query.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/repository.dart';
import '../../models/user.model.dart';

class LocalAuthentification implements AuthentificationLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  String? get _currentUid => supabaseInstance.auth.currentUser?.id;

  @override
  Future<Either<Failure, void>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final uid = _currentUid;
      if (uid == null) {
        return Left(AuthenticationFailure(message: 'Authentication failure'));
      }

      final user = UserModel(
        uid: uid,
        image: Constants.memojiDefault,
        email: email,
        username: name,
        incomes: 0.0,
        expenses: 0.0,
        balance: 0.0,
        companyIncome: 0.0,
        personalIncome: 0.0,
      );
      await Repository().upsert<UserModel>(user);
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signIn() async {
    try {
      final uid = _currentUid;
      if (uid == null) {
        return Left(AuthenticationFailure(message: 'Authentication failure'));
      }

      await Repository().get<UserModel>(
        query: Query(where: [Where.exact('uid', uid)]),
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Repository().clearLocalSessionData();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Local sign out failed: $e'));
    }
  }
}

import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/authentification/data/data_sources/local_datasource/authentification_local_datasource.dart';
import 'package:brick_core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/repository.dart';
import '../../models/user.model.dart';

class LocalAuthentification implements AuthentificationLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  /// For the local sign up process
  @override
  Future<Either<Failure, void>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final user = UserModel(
        sid: uid,
        uid: uid,
        image: 'assets/memoji/memoji_1.png',
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

  /// For the sign in process
  @override
  Future<Either<Failure, void>> signIn() async {
    try {
      await Repository().get<UserModel>(
        query: Query(where: [Where.exact('uid', uid)]),
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  /// For the sign out process
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final repo = Repository(); // ton Repository global

      // 1️⃣ Vider le cache mémoire
      repo.memoryCacheProvider.reset();

      // 2️⃣ Vider la base SQLite
      await repo.sqliteProvider.resetDb();

      return right(null);
    } catch (e) {
      return left(
        AuthenticationFailure(message: "Échec de la déconnexion locale : $e"),
      );
    }
  }
}

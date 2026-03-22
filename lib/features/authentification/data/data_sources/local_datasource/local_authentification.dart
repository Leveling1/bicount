import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/authentification/data/data_sources/local_datasource/authentification_local_datasource.dart';
import 'package:brick_core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../brick/db/schema.g.dart';
import '../../../../../brick/repository.dart';
import '../../models/user.model.dart';

class LocalAuthentification implements AuthentificationLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  @override
  Future<Either<Failure, void>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final user = UserModel(
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

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final repo = Repository();

      for (final table in schema.tables) {
        await repo.sqliteProvider.rawExecute('DELETE FROM `${table.name}`');
      }

      repo.memoryCacheProvider.reset();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Local sign out failed: $e'));
    }
  }
}

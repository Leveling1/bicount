import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/errors/failure.dart';
import '/features/authentification/domain/repositories/authentification_repository.dart';
import '/features/authentification/data/data_sources/remote_datasource/authentification_remote_datasource.dart';
import '/features/authentification/domain/entities/user.dart' as entity;
import 'package:dartz/dartz.dart';

class AuthentificationRepositoryImpl implements AuthentificationRepository {
  final AuthenticationRemoteDataSource remoteDataSource;

  AuthentificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, entity.User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email,
        password,
      );
      return Right(user);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthenticationFailure(message: e.message));
      }
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, entity.User>> signUp(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  // For the authentification with google process
  @override
  Future<Either<Failure, void>> authWithGoogle() {
    // TODO: implement authWithGoogle
    throw UnimplementedError();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data_sources/local_datasource/authentification_local_datasource.dart';
import '/core/errors/failure.dart';
import '/features/authentification/domain/repositories/authentification_repository.dart';
import '/features/authentification/data/data_sources/remote_datasource/authentification_remote_datasource.dart';
import '/features/authentification/domain/entities/user.dart' as entity;
import 'package:dartz/dartz.dart';

class AuthentificationRepositoryImpl implements AuthentificationRepository {
  final AuthenticationRemoteDataSource remoteDataSource;
  final AuthentificationLocalDataSource localDataSource;

  AuthentificationRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, entity.UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email,
        password,
      );

      final localSignIn = await localDataSource.signIn();
      if (localSignIn.isLeft()) {
        await remoteDataSource.signOut();
        return Left(AuthenticationFailure(message: "An error occurred during the sign in."));
      }
      return Right(user);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthenticationFailure(message: e.message));
      }
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, entity.UserEntity>> signUp(
    String username,
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      final localUser = await localDataSource.signUp(username, email, password);

      if (localUser.isLeft()) {
        await remoteDataSource.signOut();
        return Left(AuthenticationFailure(message: "An error occurred during registration."));
      }

      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final localSignOut = await localDataSource.signOut();
      if (localSignOut.isLeft()) {
        return Left(AuthenticationFailure(message: "An error occurred during sign out."));
      }
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

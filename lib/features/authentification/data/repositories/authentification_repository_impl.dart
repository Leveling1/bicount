import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/errors/failure.dart';
import '/features/authentification/data/data_sources/remote_datasource/authentification_remote_datasource.dart';
import '/features/authentification/domain/repositories/authentification_repository.dart';
import '../data_sources/local_datasource/authentification_local_datasource.dart';

class AuthentificationRepositoryImpl implements AuthentificationRepository {
  AuthentificationRepositoryImpl(this.localDataSource, this.remoteDataSource);

  final AuthenticationRemoteDataSource remoteDataSource;
  final AuthentificationLocalDataSource localDataSource;

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) async {
    try {
      await remoteDataSource.requestEmailOtp(email);
      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthenticationFailure(message: e.message));
      }
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailOtp(
    String email,
    String code,
  ) async {
    try {
      await remoteDataSource.verifyEmailOtp(email, code);
      final localProfile = await localDataSource.ensureCurrentUserProfile(
        emailHint: email,
      );
      if (localProfile.isLeft()) {
        await remoteDataSource.signOut();
        return Left(
          AuthenticationFailure(
            message: 'An error occurred while preparing your account.',
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthenticationFailure(message: e.message));
      }
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> authWithGoogle() async {
    try {
      final remoteUser = await remoteDataSource.authWithGoogle();

      if (remoteUser.isLeft()) {
        final failure = remoteUser.swap().getOrElse(() => throw Exception());
        return Left(
          AuthenticationFailure(message: 'Erreur : ${failure.message}'),
        );
      }

      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthenticationFailure(message: e.message));
      }
      return Left(
        AuthenticationFailure(
          message: 'Erreur lors de l\'authentification : $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> authWithApple() async {
    try {
      await remoteDataSource.authWithApple();
      return const Right(null);
    } catch (e) {
      if (e is AuthApiException) {
        return Left(AuthenticationFailure(message: e.message));
      }
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      final localSignOut = await localDataSource.signOut();

      if (localSignOut.isLeft()) {
        return Left(
          AuthenticationFailure(message: 'An error occurred during sign out.'),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }
}

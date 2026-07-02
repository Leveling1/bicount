import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
      final ensured = await _ensureLocalProfileOrRollback(emailHint: email);
      if (ensured != null) {
        return Left(ensured);
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
  Future<Either<Failure, AuthResponse>> authWithGoogle() async {
    try {
      final remoteResult = await remoteDataSource.authWithGoogle();

      if (remoteResult.isLeft()) {
        final failure = remoteResult.swap().getOrElse(() => throw Exception());
        return Left(
          AuthenticationFailure(message: 'Erreur : ${failure.message}'),
        );
      }

      final authResponse = remoteResult.getOrElse(() => throw Exception());

      final ensured = await _ensureLocalProfileOrRollback(
        emailHint: authResponse.user?.email,
      );
      if (ensured != null) {
        return Left(ensured);
      }

      return Right(authResponse);
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
      final ensured = await _ensureLocalProfileOrRollback();
      if (ensured != null) {
        return Left(ensured);
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
  Future<Either<Failure, void>> signOut() async {
    Failure? localFailure;

    try {
      await remoteDataSource.signOut();
    } catch (e) {
      debugPrint('Remote sign out warning: $e');
    } finally {
      final localSignOut = await localDataSource.signOut();
      localSignOut.fold((failure) => localFailure = failure, (_) => null);
    }

    if (localFailure != null) {
      return Left(AuthenticationFailure(message: localFailure!.message));
    }

    return const Right(null);
  }

  Future<AuthenticationFailure?> _ensureLocalProfileOrRollback({
    String? emailHint,
  }) async {
    final localProfile = await localDataSource.ensureCurrentUserProfile(
      emailHint: emailHint,
    );
    if (localProfile.isRight()) {
      return null;
    }

    await remoteDataSource.signOut();
    return AuthenticationFailure(
      message: 'An error occurred while preparing your account.',
    );
  }
}

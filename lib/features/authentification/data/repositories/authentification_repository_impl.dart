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
  Future<Either<Failure, void>> authWithGoogle({String? inviteCode}) async {
    try {
      final remoteResult = await remoteDataSource.authWithGoogle(
        inviteCode: inviteCode,
      );
      final remoteFailure = remoteResult.fold<Failure?>(
        (failure) => failure,
        (_) => null,
      );
      if (remoteFailure != null) {
        return Left(remoteFailure);
      }

      final ensured = await _ensureLocalProfileOrRollback();
      if (ensured != null) {
        return Left(ensured);
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
    final sessionReady = await _waitForAuthenticatedSession();
    if (!sessionReady) {
      await remoteDataSource.signOut();
      return AuthenticationFailure(
        message: 'An error occurred while preparing your account.',
      );
    }

    final localProfile = await _ensureCurrentUserProfileWithRetry(
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

  Future<Either<Failure, void>> _ensureCurrentUserProfileWithRetry({
    String? emailHint,
  }) async {
    final initialAttempt = await localDataSource.ensureCurrentUserProfile(
      emailHint: emailHint,
    );
    if (initialAttempt.isRight()) {
      return initialAttempt;
    }

    final failure = initialAttempt.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (failure is! AuthenticationFailure ||
        failure.message != 'Authentication failure') {
      return initialAttempt;
    }

    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final retryAttempt = await localDataSource.ensureCurrentUserProfile(
        emailHint: emailHint,
      );
      if (retryAttempt.isRight()) {
        return retryAttempt;
      }

      final retryFailure = retryAttempt.fold<Failure?>(
        (failure) => failure,
        (_) => null,
      );
      if (retryFailure is! AuthenticationFailure ||
          retryFailure.message != 'Authentication failure') {
        return retryAttempt;
      }
    }

    return initialAttempt;
  }

  Future<bool> _waitForAuthenticatedSession({
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final client = Supabase.instance.client;
    if (client.auth.currentSession != null && client.auth.currentUser != null) {
      return true;
    }

    try {
      final session = await client.auth.onAuthStateChange
          .map((authState) => authState.session)
          .firstWhere((session) => session != null)
          .timeout(timeout, onTimeout: () => null);
      return session != null ||
          (client.auth.currentSession != null &&
              client.auth.currentUser != null);
    } catch (_) {
      return client.auth.currentSession != null &&
          client.auth.currentUser != null;
    }
  }
}

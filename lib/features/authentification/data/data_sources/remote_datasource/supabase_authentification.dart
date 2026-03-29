import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/app_config.dart';
import '../../../../../core/constants/secrets.dart';
import '../../../../../core/errors/failure.dart';
import 'authentification_remote_datasource.dart';

class SupabaseAuthentification implements AuthenticationRemoteDataSource {
  SupabaseAuthentification(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<void> requestEmailOtp(String email) async {
    await supabaseClient.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  @override
  Future<void> verifyEmailOtp(String email, String code) async {
    await supabaseClient.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
  }

  @override
  Future<void> authWithApple() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      throw Exception('Apple sign-in is only available on Apple devices.');
    }

    final launched = await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: AppConfig.authUrl,
    );
    if (!launched) {
      throw Exception('Apple sign-in could not be started.');
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() async {
    try {
      final scopes = ['email', 'profile'];
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: Secrets.webIDClient,
        clientId: Secrets.iosIDClient,
      );

      final googleUser = await googleSignIn.attemptLightweightAuthentication();
      if (googleUser == null) {
        throw 'Google sign-in failed.';
      }

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);
      final idToken = googleUser.authentication.idToken;
      final accessToken = authorization.accessToken;
      if (idToken == null) {
        throw 'No Google ID token found.';
      }

      final authResponse = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user == null) {
        return Left(AuthenticationFailure(message: 'Google sign-in failed.'));
      }

      final supabaseUser = authResponse.user!;
      if (supabaseUser.email == null || supabaseUser.email!.isEmpty) {
        return Left(
          AuthenticationFailure(
            message: 'Google did not return the email needed for Bicount.',
          ),
        );
      }

      return Right(authResponse);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on TimeoutException {
      return Left(
        AuthenticationFailure(
          message: 'Google sign-in timed out. Please try again.',
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('cancel') ||
          errorMessage.contains('user_cancel')) {
        return Left(
          AuthenticationFailure(message: 'Google sign-in cancelled.'),
        );
      }
      if (errorMessage.contains('network')) {
        return Left(
          AuthenticationFailure(
            message: 'Network issue. Please check your connection.',
          ),
        );
      }

      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }
}

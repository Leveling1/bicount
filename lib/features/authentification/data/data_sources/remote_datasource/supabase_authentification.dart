import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/secrets.dart';
import '../../../../../core/errors/failure.dart';
import 'authentification_remote_datasource.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

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
    final rawNonce = supabaseClient.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
        'Could not find ID Token from generated credential.',
      );
    }
    await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    // Apple only provides the user's full name on the first sign-in
    // Save it to user metadata if available
    if (credential.givenName != null || credential.familyName != null) {
      final nameParts = <String>[];
      if (credential.givenName != null) nameParts.add(credential.givenName!);
      if (credential.familyName != null) nameParts.add(credential.familyName!);
      final fullName = nameParts.join(' ');
      await supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'given_name': credential.givenName,
            'family_name': credential.familyName,
          },
        ),
      );
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

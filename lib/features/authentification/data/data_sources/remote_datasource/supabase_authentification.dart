import 'dart:async';
import 'dart:convert';
import 'package:bicount/core/constants/test_account.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
  Future<void>? _googleSignInInitialization;

  @override
  Future<void> requestEmailOtp(String email) async {
    if (email == TestAccount.appleEmailTest ||
        email == TestAccount.googleEmailTest) {
      return;
    }
    await supabaseClient.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  @override
  Future<void> verifyEmailOtp(String email, String code) async {
    if (email == TestAccount.appleEmailTest &&
            code == TestAccount.appleOtpTest ||
        email == TestAccount.googleEmailTest &&
            code == TestAccount.googleOtpTest) {
      await connectionTest(email);
      return;
    }
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
  Future<Either<Failure, void>> authWithGoogle({String? inviteCode}) async {
    if (!_supportsNativeGoogleSignIn) {
      return _authWithGoogleWithOAuth(inviteCode: inviteCode);
    }

    try {
      await _ensureGoogleSignInInitialized();
      final googleAccount = await GoogleSignIn.instance.authenticate();
      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return Left(
          AuthenticationFailure(
            message: 'Google sign-in did not return an ID token.',
          ),
        );
      }

      await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return const Right(null);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return Left(const AuthCancelledFailure());
      }

      return Left(AuthenticationFailure(message: _googleSignInErrorMessage(e)));
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

  Future<Either<Failure, void>> _authWithGoogleWithOAuth({
    String? inviteCode,
  }) async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Secrets.buildGoogleAuthRedirectUrl(inviteCode: inviteCode),
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      return const Right(null);
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

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    final clientId = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => Secrets.iosIDClient,
      _ => null,
    };

    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: Secrets.webIDClient,
    );
  }

  bool get _supportsNativeGoogleSignIn {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  String _googleSignInErrorMessage(GoogleSignInException exception) {
    return switch (exception.code) {
      GoogleSignInExceptionCode.clientConfigurationError =>
        'Google sign-in is not configured for this build. Check the Android SHA-1, the iOS client ID, and the Supabase Google provider settings.',
      GoogleSignInExceptionCode.providerConfigurationError =>
        'Google sign-in provider is not configured correctly. Check the Google provider settings in Supabase.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google sign-in UI is unavailable on this device.',
      GoogleSignInExceptionCode.interrupted =>
        'Google sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.unknownError =>
        exception.description ?? 'Google sign-in failed. Please try again.',
      GoogleSignInExceptionCode.canceled => 'Google sign-in was cancelled.',
      GoogleSignInExceptionCode.userMismatch =>
        'Google sign-in detected a mismatched user session.',
      // ignore: unreachable_switch_case
      _ => exception.description ?? 'Google sign-in failed. Please try again.',
    };
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  Future<void> connectionTest(String email) async {
    final String password = email == TestAccount.appleEmailTest
        ? TestAccount.appleMpTest
        : TestAccount.googleMpTest;
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthApiException {
      rethrow;
    } catch (e) {
      throw AuthApiException(e.toString());
    }
  }
}

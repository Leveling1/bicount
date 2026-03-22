import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:bicount/features/authentification/data/data_sources/remote_datasource/authentification_remote_datasource.dart';

import '../../../../../core/constants/secrets.dart';
import '../../../../../core/errors/failure.dart';

class SupabaseAuthentification implements AuthenticationRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthentification(this.supabaseClient);

  @override
  Future<entity.UserEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final AuthResponse response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return entity.UserEntity(
        sid: '',
        uid: response.user!.id,
        username: '',
        email: response.user!.email ?? '',
      );
    } else {
      throw Exception('Sign in failed');
    }
  }

  @override
  Future<entity.UserEntity> signUp(String email, String password) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return entity.UserEntity(
        sid: '',
        uid: response.user!.id,
        username: '',
        email: response.user!.email ?? '',
      );
    } else {
      throw Exception('Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(email);
  }

  /// For auth with google
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
      // or await googleSignIn.authenticate(); which will return a GoogleSignInAccount or throw an exception
      if (googleUser == null) {
        throw 'Échec de la connexion avec Google.';
      }

      /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
      /// while also granting permission to access user information.
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);
      final idToken = googleUser.authentication.idToken;
      final accessToken = authorization.accessToken;
      if (idToken == null) {
        throw 'Aucun jeton d\'identification trouvé.';
      }

      final authResponse = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user == null) {
        return Left(
          AuthenticationFailure(
            message: 'Échec de l\'authentification avec Google',
          ),
        );
      }

      final supabaseUser = authResponse.user!;

      // Validate user email
      if (supabaseUser.email == null || supabaseUser.email!.isEmpty) {
        return Left(
          AuthenticationFailure(message: 'Email non fourni par Google'),
        );
      }

      // Retourne true si le lancement du navigateur a réussi
      return Right(authResponse);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on TimeoutException {
      return Left(
        AuthenticationFailure(
          message: 'Délai de connexion dépassé. Veuillez réessayer.',
        ),
      );
    } catch (e) {
      // Check for common Google Sign-In errors
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('cancel') ||
          errorMessage.contains('user_cancel')) {
        return Left(AuthenticationFailure(message: 'Connexion Google annulée'));
      } else if (errorMessage.contains('network')) {
        return Left(
          AuthenticationFailure(
            message: ' réseau. Veuillez vérifier votre connexion.',
          ),
        );
      }
      return Left(
        AuthenticationFailure(
          message: 'L\'authentification avec Google a échoué : ${e.toString()}',
        ),
      );
    }
  }
}

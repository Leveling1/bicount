import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bicount/features/authentification/data/models/user_model.dart';
import 'package:bicount/features/authentification/data/data_sources/remote_datasource/authentification_remote_datasource.dart';

class SupabaseAuthentification implements AuthenticationRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthentification(this.supabaseClient);

  @override
  Future<entity.User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final AuthResponse response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return UserModel.fromSupabase(response.user!);
    } else {
      throw Exception('Sign in failed');
    }
  }

  @override
  Future<entity.User> signUp(String email, String password) async {
    final AuthResponse response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return UserModel.fromSupabase(response.user!);
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
}

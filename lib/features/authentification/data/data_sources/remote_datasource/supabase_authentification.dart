import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:dartz/dartz.dart' as user;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/authentification/data/data_sources/remote_datasource/authentification_remote_datasource.dart';

class SupabaseAuthentification implements AuthenticationRemoteDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthentification(this.supabaseClient);

  @override
  Future<entity.UserEntity> signInWithEmailAndPassword(String email, String password,) async {
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
}

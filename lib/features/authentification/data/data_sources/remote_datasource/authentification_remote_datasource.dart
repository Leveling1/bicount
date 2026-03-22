import 'package:bicount/features/authentification/domain/entities/user.dart'
    as entity;
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/errors/failure.dart';

abstract class AuthenticationRemoteDataSource {
  Future<entity.UserEntity> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<entity.UserEntity> signUp(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<Either<Failure, AuthResponse>> authWithGoogle();
}

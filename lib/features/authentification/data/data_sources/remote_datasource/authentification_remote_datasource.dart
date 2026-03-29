import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/errors/failure.dart';

abstract class AuthenticationRemoteDataSource {
  Future<void> requestEmailOtp(String email);
  Future<void> verifyEmailOtp(String email, String code);
  Future<void> signOut();
  Future<void> authWithApple();
  Future<Either<Failure, AuthResponse>> authWithGoogle();
}

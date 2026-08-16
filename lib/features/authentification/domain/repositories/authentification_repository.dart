import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthentificationRepository {
  Future<Either<Failure, void>> requestEmailOtp(String email);

  Future<Either<Failure, void>> verifyEmailOtp(String email, String code);

  /// [forgetNotificationChoices] clears the per-device notification answers
  /// too, so the next account is asked again. Reserved for account deletion.
  Future<Either<Failure, void>> signOut({bool forgetNotificationChoices});

  Future<Either<Failure, AuthResponse>> authWithGoogle();

  Future<Either<Failure, void>> authWithApple();
}

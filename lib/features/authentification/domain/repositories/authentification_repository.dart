import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthentificationRepository {
  Future<Either<Failure, void>> requestEmailOtp(String email);
  Future<Either<Failure, void>> verifyEmailOtp(String email, String code);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> authWithGoogle();
  Future<Either<Failure, void>> authWithApple();
}

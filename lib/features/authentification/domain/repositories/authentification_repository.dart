import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

abstract class AuthentificationRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signUp(String username, String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  // For the authentification with google process
  Future<Either<Failure, void>> authWithGoogle();
}

import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

abstract class AuthentificationRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, User>> signUp(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}

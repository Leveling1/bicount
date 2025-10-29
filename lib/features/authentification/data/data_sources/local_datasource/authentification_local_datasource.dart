import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthentificationLocalDataSource {
  // For the sign up process
  Future<Either<Failure, void>> signUp(String name, String email, String password);

  // For the sign in process
  Future<Either<Failure, void>> signIn();

  // For the log out process
  Future<Either<Failure, void>> signOut();
}

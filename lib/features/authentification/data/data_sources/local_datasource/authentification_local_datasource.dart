import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthentificationLocalDataSource {
  Future<Either<Failure, void>> ensureCurrentUserProfile({String? emailHint});

  // For the log out process
  Future<Either<Failure, void>> signOut();
}

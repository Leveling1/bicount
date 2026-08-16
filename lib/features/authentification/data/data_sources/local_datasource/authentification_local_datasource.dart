import '/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthentificationLocalDataSource {
  Future<Either<Failure, void>> ensureCurrentUserProfile({String? emailHint});

  // For the log out process
  /// [forgetNotificationChoices] also drops the per-device notification
  /// answers, so the next account is prompted again. Used when the account is
  /// deleted rather than simply signed out.
  Future<Either<Failure, void>> signOut({bool forgetNotificationChoices});
}

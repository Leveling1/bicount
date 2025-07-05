part of 'authentification_bloc.dart';

abstract class AuthentificationState {}

class AuthentificationInitial extends AuthentificationState {}
class AuthentificationFailure extends AuthentificationState {}
class AuthentificationLoading extends AuthentificationState {}
class AuthentificationSuccess extends AuthentificationState {}

class SignUpLoading extends AuthentificationLoading {}
class SignUpSuccess extends AuthentificationSuccess {}
class SignUpFailure extends AuthentificationFailure {
  final String error;
  SignUpFailure({required this.error});
}

class SignInLoading extends AuthentificationLoading {}
class SignInSuccess extends AuthentificationSuccess {}
class SignInFailure extends AuthentificationState {
  final String error;
  SignInFailure({required this.error});
}

class SignOutLoading extends AuthentificationLoading {}
class SignOutSuccess extends AuthentificationSuccess {}
class SignOutFailure extends AuthentificationFailure {
  final String error;
  SignOutFailure({required this.error});
}

class SendPasswordResetEmailLoading extends AuthentificationLoading {}
class SendPasswordResetEmailSuccess extends AuthentificationState {}
class SendPasswordResetEmailFailure extends AuthentificationFailure {
  final String error;
  SendPasswordResetEmailFailure({required this.error});
}

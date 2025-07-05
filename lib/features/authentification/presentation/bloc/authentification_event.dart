part of 'authentification_bloc.dart';

abstract class AuthentificationEvent {}

// Add your events here
class ExampleAuthentificationEvent extends AuthentificationEvent {}

class SignUpEvent extends AuthentificationEvent {
  final String email;
  final String password;

  SignUpEvent({required this.email, required this.password});
}

class SignInEvent extends AuthentificationEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});
}

class SignOutEvent extends AuthentificationEvent {}

class SendPasswordResetEmailEvent extends AuthentificationEvent {
  final String email;
  SendPasswordResetEmailEvent({required this.email});
}

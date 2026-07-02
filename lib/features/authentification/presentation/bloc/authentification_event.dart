part of 'authentification_bloc.dart';

abstract class AuthentificationEvent {}

class RequestEmailOtpEvent extends AuthentificationEvent {
  RequestEmailOtpEvent({required this.email});

  final String email;
}

class VerifyEmailOtpEvent extends AuthentificationEvent {
  VerifyEmailOtpEvent({required this.email, required this.code});

  final String email;
  final String code;
}

class AuthWithGoogleEvent extends AuthentificationEvent {}

class AuthWithAppleEvent extends AuthentificationEvent {}

class SignOutEvent extends AuthentificationEvent {}

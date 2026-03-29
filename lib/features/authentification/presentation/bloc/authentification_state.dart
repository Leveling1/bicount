part of 'authentification_bloc.dart';

abstract class AuthentificationState {}

class AuthentificationInitial extends AuthentificationState {}

class RequestEmailOtpLoading extends AuthentificationState {}

class RequestEmailOtpSuccess extends AuthentificationState {
  RequestEmailOtpSuccess({required this.email});

  final String email;
}

class RequestEmailOtpFailure extends AuthentificationState {
  RequestEmailOtpFailure({required this.error});

  final String error;
}

class VerifyEmailOtpLoading extends AuthentificationState {}

class VerifyEmailOtpSuccess extends AuthentificationState {}

class VerifyEmailOtpFailure extends AuthentificationState {
  VerifyEmailOtpFailure({required this.error});

  final String error;
}

class AuthWithGoogleLoading extends AuthentificationState {}

class AuthWithGoogleSuccess extends AuthentificationState {}

class AuthWithGoogleFailure extends AuthentificationState {
  AuthWithGoogleFailure({required this.error});

  final String error;
}

class AuthWithAppleLoading extends AuthentificationState {}

class AuthWithAppleSuccess extends AuthentificationState {}

class AuthWithAppleFailure extends AuthentificationState {
  AuthWithAppleFailure({required this.error});

  final String error;
}

class SignOutLoading extends AuthentificationState {}

class SignOutSuccess extends AuthentificationState {}

class SignOutFailure extends AuthentificationState {
  SignOutFailure({required this.error});

  final String error;
}

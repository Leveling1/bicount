import 'package:bicount/features/authentification/domain/repositories/authentification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'authentification_event.dart';
part 'authentification_state.dart';

class AuthentificationBloc
    extends Bloc<AuthentificationEvent, AuthentificationState> {
  AuthentificationBloc({required this.authentificationRepository})
    : super(AuthentificationInitial()) {
    on<RequestEmailOtpEvent>(_requestEmailOtp);
    on<VerifyEmailOtpEvent>(_verifyEmailOtp);
    on<AuthWithGoogleEvent>(_authWithGoogle);
    on<AuthWithAppleEvent>(_authWithApple);
    on<SignOutEvent>(_signOut);
  }

  final AuthentificationRepository authentificationRepository;

  Future<void> _requestEmailOtp(
    RequestEmailOtpEvent event,
    Emitter<AuthentificationState> emit,
  ) async {
    emit(RequestEmailOtpLoading());
    final result = await authentificationRepository.requestEmailOtp(
      event.email,
    );
    result.fold(
      (failure) => emit(RequestEmailOtpFailure(error: failure.message)),
      (_) => emit(RequestEmailOtpSuccess(email: event.email)),
    );
  }

  Future<void> _verifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthentificationState> emit,
  ) async {
    emit(VerifyEmailOtpLoading());
    final result = await authentificationRepository.verifyEmailOtp(
      event.email,
      event.code,
    );
    result.fold(
      (failure) => emit(VerifyEmailOtpFailure(error: failure.message)),
      (_) => emit(VerifyEmailOtpSuccess()),
    );
  }

  Future<void> _authWithGoogle(
    AuthWithGoogleEvent event,
    Emitter<AuthentificationState> emit,
  ) async {
    emit(AuthWithGoogleLoading());
    final result = await authentificationRepository.authWithGoogle();
    result.fold(
      (failure) => emit(AuthWithGoogleFailure(error: failure.message)),
      (_) => emit(AuthWithGoogleSuccess()),
    );
  }

  Future<void> _authWithApple(
    AuthWithAppleEvent event,
    Emitter<AuthentificationState> emit,
  ) async {
    emit(AuthWithAppleLoading());
    final result = await authentificationRepository.authWithApple();
    result.fold(
      (failure) => emit(AuthWithAppleFailure(error: failure.message)),
      (_) => emit(AuthWithAppleSuccess()),
    );
  }

  Future<void> _signOut(
    SignOutEvent event,
    Emitter<AuthentificationState> emit,
  ) async {
    emit(SignOutLoading());
    final result = await authentificationRepository.signOut();
    result.fold(
      (failure) => emit(SignOutFailure(error: failure.message)),
      (_) => emit(SignOutSuccess()),
    );
  }
}

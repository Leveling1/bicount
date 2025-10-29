import 'package:bicount/features/authentification/domain/repositories/authentification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'authentification_event.dart';
part 'authentification_state.dart';

class AuthentificationBloc
    extends Bloc<AuthentificationEvent, AuthentificationState> {
  final AuthentificationRepository authentificationRepository;

  AuthentificationBloc({required this.authentificationRepository})
    : super(AuthentificationInitial()) {
    // For the sign up process
    on<SignUpEvent>(_signUp);

    // For the sign in process
    on<SignInEvent>(_signIn);

    // For the authentification with google process
    on<AuthWithGoogleEvent>(_authWithGoogle);
  }

  /// For the sign in process
  // With email and password
  Future<void> _signUp(SignUpEvent event, Emitter<AuthentificationState> emit) async {
    emit(SignUpLoading());
    final result = await authentificationRepository.signUp(
      event.username,
      event.email,
      event.password,
    );
    result.fold(
      (failure) => emit(SignUpFailure(error: failure.message)),
      (user) => emit(SignUpSuccess()),
    );
  }

  /// For the login process
  // With email and password
  Future<void> _signIn(SignInEvent event, Emitter<AuthentificationState> emit) async {
    emit(SignInLoading());
    final result = await authentificationRepository.signInWithEmailAndPassword(
      event.email,
      event.password
    );
    result.fold(
      (failure) => emit(SignInFailure(error: failure.message)),
      (user) => emit(SignInSuccess()),
    );
  }

  /// For the authentification process
  // With Google
  Future<void> _authWithGoogle(AuthWithGoogleEvent event, Emitter<AuthentificationState> emit) async {
    emit(AuthWithGoogleLoading());
    final result = await authentificationRepository.authWithGoogle();
    result.fold(
      (failure) => emit(AuthWithGoogleFailure(error: failure.message)),
      (user) => emit(AuthWithGoogleSuccess()),
    );
  }

}

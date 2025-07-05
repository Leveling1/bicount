import 'package:bicount/features/authentification/domain/repositories/authentification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'authentification_event.dart';
part 'authentification_state.dart';

class AuthentificationBloc
    extends Bloc<AuthentificationEvent, AuthentificationState> {
  final AuthentificationRepository authentificationRepository;

  AuthentificationBloc({required this.authentificationRepository})
    : super(AuthentificationInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(SignUpLoading());
      final result = await authentificationRepository.signUp(
        event.email,
        event.password,
      );
      result.fold(
        (failure) => emit(SignUpFailure(error: failure.message)),
        (user) => emit(SignUpSuccess()),
      );
    });
    on<SignInEvent>((event, emit) async {
      emit(SignInLoading());
      final result = await authentificationRepository
          .signInWithEmailAndPassword(event.email, event.password);
      result.fold(
        (failure) => emit(SignInFailure(error: failure.message)),
        (user) => emit(SignInSuccess()),
      );
    });
  }
}

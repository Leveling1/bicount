import 'package:flutter_bloc/flutter_bloc.dart';
part 'authentification_event.dart';
part 'authentification_state.dart';
class AuthentificationBloc extends Bloc<AuthentificationEvent, AuthentificationState> {
  AuthentificationBloc() : super(AuthentificationInitial()) {
    // Add your event handlers here
  }
}

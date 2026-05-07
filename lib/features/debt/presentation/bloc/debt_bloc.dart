import 'package:flutter_bloc/flutter_bloc.dart';
part 'debt_event.dart';
part 'debt_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  DebtBloc() : super(DebtInitial()) {
    // Add your event handlers here
  }
}

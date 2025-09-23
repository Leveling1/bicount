import 'package:flutter_bloc/flutter_bloc.dart';
part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc() : super(GroupInitial()) {
    // Add your event handlers here
  }
}

import 'package:bicount/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(ProfileRepositoryImpl read) : super(ProfileInitial()) {
    // Add your event handlers here
  }
}

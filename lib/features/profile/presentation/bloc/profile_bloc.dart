import 'package:bicount/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepositoryImpl repository;
  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<AddAccountFundingEvent>(_addAccountFunding);
  }
  Future<void> _addAccountFunding(
      AddAccountFundingEvent event, Emitter<ProfileState> emit) async {
    emit(AccountFundingLoading());
    try {
      await repository.addAccountFunding(event.data);
      emit(AccountFundingAdded());
    } catch (e) {
      emit(AccountFundingError(e.toString()));
    }
  }
}

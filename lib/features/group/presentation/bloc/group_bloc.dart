import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/group_model.dart';
import '../../domain/entities/member_model.dart';
import '../../domain/repositories/group_repository.dart';
part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository repository;
  GroupBloc(this.repository) : super(GroupInitial()) {
    on<CreateGroupEvent>(_onCreateGroup);
    on<GetAllGroupDetails>(_onGetAllGroupDetails);
  }

  Future<void> _onCreateGroup(CreateGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      final createdGroup =
      await repository.createGroup(event.group, event.logoFile);
      emit(GroupCreated(createdGroup));
    } catch (e) {
      emit(GroupError(e is Failure ? e : UnknownFailure()));
    }
  }

  Future<void> _onGetAllGroupDetails(GetAllGroupDetails event, Emitter<GroupState> emit) async {
    emit(GroupDetailsLoading());
    try {
      final members = await repository.getAllGroupDetails(event.group);
      emit(GroupDetailsLoaded(members));
    } catch (e) {
      emit(GroupError(e is Failure ? e : UnknownFailure()));
    }
  }
}
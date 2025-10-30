part of 'group_bloc.dart';

abstract class GroupState {}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupCreated extends GroupState {
  final GroupEntity group;
  GroupCreated(this.group);
}

class GroupError extends GroupState {
  final Failure failure;
  GroupError(this.failure);
}

class GroupDetailsLoading extends GroupState {}

class GroupDetailsLoaded extends GroupState {
  final List<MemberModel> members;
  GroupDetailsLoaded(this.members);
}

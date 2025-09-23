part of 'group_bloc.dart';

abstract class GroupState {}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupCreated extends GroupState {
  final GroupModel group;
  GroupCreated(this.group);
}

class GroupError extends GroupState {
  final Failure failure;
  GroupError(this.failure);
}

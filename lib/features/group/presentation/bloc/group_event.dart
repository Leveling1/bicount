part of 'group_bloc.dart';

abstract class GroupEvent {}

class CreateGroupEvent extends GroupEvent {
  final GroupModel group;
  final File? logoFile;
  CreateGroupEvent(this.group, {this.logoFile});
}

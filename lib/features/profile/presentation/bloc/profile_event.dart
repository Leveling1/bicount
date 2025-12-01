part of 'profile_bloc.dart';

abstract class ProfileEvent {}

// Add your events here
class AddAccountFundingEvent extends ProfileEvent {
  final AddAccountFundingEntity data;
  AddAccountFundingEvent({required this.data});
}

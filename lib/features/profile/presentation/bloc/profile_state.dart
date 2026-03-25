part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class AccountFundingLoading extends ProfileState {}

class AccountFundingAdded extends ProfileState {
  AccountFundingAdded({required this.isRecurring});

  final bool isRecurring;
}

class AccountFundingError extends ProfileState {
  final String message;

  AccountFundingError(this.message);
}

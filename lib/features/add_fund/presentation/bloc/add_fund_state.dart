part of 'add_fund_bloc.dart';

abstract class AddFundState {
  const AddFundState();
}

class AddFundInitial extends AddFundState {}

class AddFundSaving extends AddFundState {}

class AddFundSaved extends AddFundState {
  const AddFundSaved({required this.isRecurring, this.isUpdated = false});

  final bool isRecurring;
  final bool isUpdated;
}

class AddFundDeleted extends AddFundState {}

class AddFundFailure extends AddFundState {
  const AddFundFailure(this.message);

  final String message;
}

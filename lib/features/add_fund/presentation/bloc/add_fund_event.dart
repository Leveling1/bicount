part of 'add_fund_bloc.dart';

abstract class AddFundEvent {
  const AddFundEvent();
}

class AddFundSubmitted extends AddFundEvent {
  const AddFundSubmitted({required this.data});

  final AddAccountFundingEntity data;
}

class AddFundUpdated extends AddFundEvent {
  const AddFundUpdated({required this.data});

  final AddAccountFundingEntity data;
}

class AddFundDeleteRequested extends AddFundEvent {
  const AddFundDeleteRequested({required this.funding});

  final AccountFundingModel funding;
}

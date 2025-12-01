import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';

abstract class ProfileLocalDataSource {
  Future<void> addAccountFunding(AddAccountFundingEntity data);
}

import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/domain/entities/add_account_funding_entity.dart';

abstract class AddFundLocalDataSource {
  Future<void> addAccountFunding(AddAccountFundingEntity data);
  Future<void> deleteAccountFunding(AccountFundingModel funding);
  Future<void> updateAccountFunding(AddAccountFundingEntity data);
}

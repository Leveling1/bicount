import 'package:bicount/features/add_fund/domain/entities/add_account_funding_entity.dart';

abstract class AddFundRepository {
  Future<void> addAccountFunding(AddAccountFundingEntity data);
  Future<void> updateAccountFunding(AddAccountFundingEntity data);
}

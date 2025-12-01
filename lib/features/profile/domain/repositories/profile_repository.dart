
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';

abstract class ProfileRepository {
  Future<void> addAccountFunding(AddAccountFundingEntity data);
}

import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/add_fund/data/data_sources/local_datasource/add_fund_local_datasource.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/domain/entities/add_account_funding_entity.dart';
import 'package:bicount/features/add_fund/domain/repositories/add_fund_repository.dart';

class AddFundRepositoryImpl implements AddFundRepository {
  AddFundRepositoryImpl({required this.localDataSource});

  final AddFundLocalDataSource localDataSource;

  @override
  Future<void> addAccountFunding(AddAccountFundingEntity data) async {
    try {
      await localDataSource.addAccountFunding(data);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to save this account funding right now.',
      );
    }
  }

  @override
  Future<void> deleteAccountFunding(AccountFundingModel funding) async {
    try {
      await localDataSource.deleteAccountFunding(funding);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to delete this account funding right now.',
      );
    }
  }

  @override
  Future<void> updateAccountFunding(AddAccountFundingEntity data) async {
    try {
      await localDataSource.updateAccountFunding(data);
    } on Failure {
      rethrow;
    } catch (_) {
      throw MessageFailure(
        message: 'Unable to update this account funding right now.',
      );
    }
  }
}

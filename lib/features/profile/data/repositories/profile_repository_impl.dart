import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/profile/data/data_sources/local_datasource/profile_local_data_source_impl.dart';
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';

import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSourceImpl localDataSource;
  ProfileRepositoryImpl({required this.localDataSource});

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

  // Add your repository implementation here
}

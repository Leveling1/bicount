import 'package:bicount/features/profile/data/data_sources/local_datasource/profile_local_data_source_impl.dart';
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';

import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSourceImpl localDataSource;
  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addAccountFunding(AddAccountFundingEntity data) {
    try {
      return localDataSource.addAccountFunding(data);
    } catch (e) {
      throw '.';
    }
  }
  // Add your repository implementation here
}

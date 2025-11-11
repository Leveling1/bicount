import '../data_sources/local_datasource/home_local_datasource.dart';
import '../data_sources/remote_datasource/home_remote_datasource.dart';
import '/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  HomeRepositoryImpl(this.remoteDataSource, this.localDataSource);
}

import 'package:bicount/features/main/domain/entities/main_entity.dart';

abstract class MainRepository {
  //Stream<NetworkStatus> get networkStatus;
  Future<void> reconcileDeletedRecords();
  Stream<MainEntity> getStartDataStream();
}

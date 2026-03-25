import 'package:bicount/features/main/domain/entities/main_entity.dart';

abstract class MainRepository {
  //Stream<NetworkStatus> get networkStatus;
  Future<void> reconcileDeletedRecords();
  Future<void> processRecurringFundings();
  Stream<MainEntity> getStartDataStream();
}

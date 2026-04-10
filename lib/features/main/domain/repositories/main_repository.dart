import 'package:bicount/features/main/domain/entities/main_entity.dart';

abstract class MainRepository {
  Future<void> reconcileDeletedRecords();
  Stream<MainEntity> getStartDataStream();
  Future<void> forceHydrate();
}


import 'package:bicount/features/main/domain/entities/main_entity.dart';

enum NetworkStatus { connected, disconnected, unstable }
abstract class MainRepository {
  //Stream<NetworkStatus> get networkStatus;
  Stream<MainEntity> getStartDataStream();
}

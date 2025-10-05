import '../../data/models/start.model.dart';

enum NetworkStatus { connected, disconnected, unstable }
abstract class MainRepository {
  Stream<NetworkStatus> get networkStatus;
  Stream<List<Start>> get startData;
}

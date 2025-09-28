
enum NetworkStatus { connected, disconnected, unstable }
abstract class MainRepository {
  Stream<NetworkStatus> get networkStatus;
}

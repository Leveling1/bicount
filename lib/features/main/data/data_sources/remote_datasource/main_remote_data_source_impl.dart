import 'dart:io';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bicount/core/constants/constants.dart';

class MainRemoteDataSourceImpl implements MainRemoteDataSource {
  @override
  Stream<int> connectionState() async* {
    final connectivity = Connectivity();

    yield await _mapConnectivityResults(await connectivity.checkConnectivity());
    yield* connectivity.onConnectivityChanged.asyncMap(_mapConnectivityResults);
  }

  Future<int> _mapConnectivityResults(List<ConnectivityResult> results) async {
    final isConnectedType = results.any((r) => r != ConnectivityResult.none);
    if (!isConnectedType) {
      return Constants.disconnected;
    }

    return await _hasNetwork() ? Constants.connected : Constants.disconnected;
  }

  // Test réseau simple via une requête DNS
  Future<bool> _hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

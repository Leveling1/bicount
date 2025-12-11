import 'dart:io';
import 'package:bicount/features/main/data/data_sources/remote_datasource/main_remote_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bicount/core/constants/constants.dart';

class MainRemoteDataSourceImpl implements MainRemoteDataSource {
  @override
  Stream<int> connectionState() {
    // On écoute le flux de connectivité
    return Connectivity()
        .onConnectivityChanged
        .asyncMap((List<ConnectivityResult> results) async {
      // Vérifie d'abord s'il y a une connectivité autre que none
      final isConnectedType = results.any((r) => r != ConnectivityResult.none);
      if (!isConnectedType) {
        return Constants.disconnected;
      }
      // Vérification réelle: test d'accès à Internet
      final hasInternet = await _hasNetwork();
      if (hasInternet) {
        return Constants.connected;
      } else {
        return Constants.disconnected;
      }
    });
  }

  // Test réseau simple via une requête DNS
  Future<bool> _hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}

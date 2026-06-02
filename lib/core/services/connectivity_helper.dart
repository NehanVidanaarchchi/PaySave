import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternetConnection() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();

    return _hasConnection(results);
  }

  Stream<List<ConnectivityResult>> get connectionStream {
    return _connectivity.onConnectivityChanged;
  }

  Stream<bool> get hasConnectionStream {
    return _connectivity.onConnectivityChanged.map(_hasConnection).distinct();
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }
}

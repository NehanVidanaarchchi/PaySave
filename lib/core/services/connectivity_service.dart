import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityService {

  final Connectivity _connectivity =
      Connectivity();


  Stream<bool> get connectionStream {

    return _connectivity
        .onConnectivityChanged
        .map(
          (result) {

            return result !=
                ConnectivityResult.none;

          },
        );

  }


  Future<bool> checkConnection() async {

    final result =
        await _connectivity.checkConnectivity();


    return result !=
        ConnectivityResult.none;

  }

}
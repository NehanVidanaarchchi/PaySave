import 'dart:async';

import 'package:flutter/material.dart';

import '../core/services/connectivity_service.dart';


class ConnectivityProvider
    extends ChangeNotifier {


  final ConnectivityService _service =
      ConnectivityService();


  bool _hasInternet = true;


  bool get hasInternet =>
      _hasInternet;



  StreamSubscription?
      _subscription;



  ConnectivityProvider(){

    _startListening();

  }



  void _startListening(){

    _subscription =
        _service.connectionStream.listen(
      (status){

        _hasInternet =
            status;

        notifyListeners();

      },
    );

  }



  Future<void> checkNow() async {


    _hasInternet =
        await _service.checkConnection();


    notifyListeners();

  }



  @override
  void dispose(){

    _subscription?.cancel();

    super.dispose();

  }

}
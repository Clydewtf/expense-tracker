import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';


class NetworkService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  VoidCallback? onReconnect;
  VoidCallback? onReconnectWithBloc;

  NetworkService() {
    _init();
  }

  void triggerReconnect() {
    if (onReconnect != null) onReconnect!();
    if (onReconnectWithBloc != null) onReconnectWithBloc!();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      final connected = result != ConnectivityResult.none;

      if (connected != _isOnline) {
        _isOnline = connected;
        notifyListeners();

        if (connected) {
        if (onReconnect != null) onReconnect!();
        if (onReconnectWithBloc != null) onReconnectWithBloc!();
      }
      }
    });

    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
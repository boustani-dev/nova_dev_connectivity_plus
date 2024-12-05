import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionCheck {
  ConnectionCheck._privateConstructor();
  static final ConnectionCheck _instance =
      ConnectionCheck._privateConstructor();
  factory ConnectionCheck() => _instance;

  final Connectivity _connectivity = Connectivity();

  // Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // Method to get the current connectivity status
  Future<List<ConnectivityResult>> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return [ConnectivityResult.none];
    }
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline }

class ConnectivityNotifier extends StateNotifier<NetworkStatus> {
  ConnectivityNotifier() : super(NetworkStatus.online) {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // If list contains 'none' it means disconnected? 
      // Actually package behavior: if any is not none, we have some connection (wifi/mobile)
      // But 'none' means completely disconnected.
      final isOffline = results.contains(ConnectivityResult.none);
      state = isOffline ? NetworkStatus.offline : NetworkStatus.online;
    });
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, NetworkStatus>((ref) {
  return ConnectivityNotifier();
});

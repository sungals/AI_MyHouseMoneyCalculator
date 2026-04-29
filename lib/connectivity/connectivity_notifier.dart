import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(true) {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    try {
      // Check initial connectivity
      final results = await _connectivity.checkConnectivity();
      state = _isConnected(results);

      // Listen to connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          state = _isConnected(results);
        },
      );
    } catch (_) {
      // Assume online if we can't check connectivity
      state = true;
    }
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

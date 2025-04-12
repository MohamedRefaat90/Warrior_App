import 'dart:async';

import 'package:Warrior/core/services/sync.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityChecker {
  static bool? isOnline;
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isOnline = !connectivityResult.contains(ConnectivityResult.none);
    return isOnline!;
  }

  static void dispose() {
    _subscription?.cancel();
  }

  static void initialize(WidgetRef ref) {
    // Initial check
    checkConnectivity();

    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      final wasOffline = isOnline == false;
      isOnline = !result.contains(ConnectivityResult.none);

      // If we're coming back online and we were offline before
      if (isOnline! && wasOffline) {
        debugPrint('Connection restored. Syncing data...');

        // Start sync
        // ref.read(syncingProvider.notifier).state = true;

        // Get sync service and sync

        await ref.read(syncServiceProvider.notifier).syncPendingOperations();

        // End sync
        // ref.read(syncingProvider.notifier).state = false;
      }
    });
  }
}

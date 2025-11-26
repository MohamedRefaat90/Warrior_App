import 'dart:async';

import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ConnectivityChecker {
  static bool? isOnline;
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static Future<bool> checkConnectivity() async {
    // On web, connectivity_plus is unreliable, so we do an actual network check
    if (kIsWeb) {
      isOnline = await _checkInternetConnection();
      return isOnline!;
    }

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

    // On web, we can't rely on connectivity_plus stream,
    // so we'll just set isOnline to true by default and let API calls handle errors
    if (kIsWeb) {
      isOnline = true;
      TalkerService.info(
          'Web platform detected - assuming online', 'CONNECTIVITY');
      return;
    }

    // Listen for changes (non-web platforms only)
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      final wasOffline = isOnline == false;
      isOnline = !result.contains(ConnectivityResult.none);

      // If we're coming back online and we were offline before
      if (isOnline! && wasOffline) {
        TalkerService.info(
            'Connection restored. Syncing data...', 'CONNECTIVITY');

        // Start sync
        // ref.read(syncingProvider.notifier).state = true;

        // Get sync service and sync

        await ref.read(syncServiceProvider.notifier).syncPendingOperations();

        // End sync
        // ref.read(syncingProvider.notifier).state = false;
      }
    });
  }

  /// Performs an actual HTTP request to verify internet connectivity
  /// This is more reliable than connectivity_plus on web
  static Future<bool> _checkInternetConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://www.google.com/generate_204'),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      TalkerService.warning('Internet check failed: $e', 'CONNECTIVITY');
      return false;
    }
  }
}

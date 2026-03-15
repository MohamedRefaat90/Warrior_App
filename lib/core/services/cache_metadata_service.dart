import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';

/// Persists and compares lightweight cache metadata (last_updated timestamp
/// and item count) for each remote resource. This lets the app decide whether
/// a full API refresh is needed without fetching the full dataset.
class CacheMetadataService {
  static const String _lastUpdatedSuffix = '_last_updated';
  static const String _countSuffix = '_count';

  /// Resource keys used across the app.
  static const String muscles = 'muscles';
  static const String predefinedWorkouts = 'predefined_workouts';

  /// Returns `true` when [serverLastUpdated] or [serverCount] differ from what
  /// is stored locally for [key], meaning the app should fetch fresh data.
  ///
  /// Returns `true` if no metadata has been stored yet (first launch).
  static bool needsRefresh({
    required String key,
    required String? serverLastUpdated,
    required int serverCount,
  }) {
    final storedLastUpdated = SharedPref.getString('$key$_lastUpdatedSuffix');
    final storedCount = SharedPref.getInt('$key$_countSuffix');

    if (storedLastUpdated == null || storedCount == null) {
      TalkerService.info(
        'No cache metadata for "$key" — refresh required',
        'CACHE_META',
      );
      return true;
    }

    final changed = storedLastUpdated != serverLastUpdated ||
        storedCount != serverCount;

    if (changed) {
      TalkerService.info(
        '"$key" changed on server '
        '(was: $storedLastUpdated/$storedCount, '
        'now: $serverLastUpdated/$serverCount) — refresh required',
        'CACHE_META',
      );
    } else {
      TalkerService.info(
        '"$key" is up-to-date — using cached data',
        'CACHE_META',
      );
    }

    return changed;
  }

  /// Persists [lastUpdated] and [count] for [key] after a successful full
  /// data fetch so future calls to [needsRefresh] can compare against them.
  static Future<void> updateMetadata({
    required String key,
    required String? lastUpdated,
    required int count,
  }) async {
    await SharedPref.setString(
      '$key$_lastUpdatedSuffix',
      lastUpdated ?? '',
    );
    await SharedPref.setInt('$key$_countSuffix', count);
    TalkerService.info(
      'Updated cache metadata for "$key": $lastUpdated / $count items',
      'CACHE_META',
    );
  }

  /// Clears stored metadata for [key], forcing a full refresh on next check.
  static Future<void> invalidate(String key) async {
    await SharedPref.prefs?.remove('$key$_lastUpdatedSuffix');
    await SharedPref.prefs?.remove('$key$_countSuffix');
    TalkerService.info('Invalidated cache metadata for "$key"', 'CACHE_META');
  }
}

import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cacheStatusRepositoryProvider = Provider<CacheStatusRepository>((ref) {
  return CacheStatusRepository(ref.read(dioProvider));
});

/// Model representing the cache metadata for a single resource.
class ResourceCacheStatus {
  const ResourceCacheStatus({
    required this.lastUpdated,
    required this.count,
  });

  final String? lastUpdated;
  final int count;

  factory ResourceCacheStatus.fromMap(Map<String, dynamic> map) {
    return ResourceCacheStatus(
      lastUpdated: map['last_updated'] as String?,
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Response model for the `/cache-status/` endpoint.
class CacheStatusResponse {
  const CacheStatusResponse({
    required this.muscles,
    required this.predefinedWorkouts,
  });

  final ResourceCacheStatus muscles;
  final ResourceCacheStatus predefinedWorkouts;

  factory CacheStatusResponse.fromMap(Map<String, dynamic> map) {
    return CacheStatusResponse(
      muscles: ResourceCacheStatus.fromMap(
        map['muscles'] as Map<String, dynamic>,
      ),
      predefinedWorkouts: ResourceCacheStatus.fromMap(
        map['predefined_workouts'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Fetches lightweight aggregate metadata from the backend `/cache-status/`
/// endpoint. The response is tiny (~100 bytes) and the backend caches it for
/// 5 minutes, so calling it on every screen navigation has negligible cost.
class CacheStatusRepository {
  CacheStatusRepository(this._dio);

  final Dio _dio;

  Future<CacheStatusResponse?> fetchCacheStatus() async {
    try {
      final response = await _dio.get(ApisUrl.cacheStatus);
      final data = response.data['data'] as Map<String, dynamic>;
      return CacheStatusResponse.fromMap(data);
    } on DioException catch (e) {
      TalkerService.error(
        'Failed to fetch cache status — will use cached data',
        'CACHE_STATUS',
        e,
      );
      return null;
    } catch (e) {
      TalkerService.error(
        'Unexpected error fetching cache status',
        'CACHE_STATUS',
        e,
      );
      return null;
    }
  }
}

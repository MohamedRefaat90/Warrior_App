import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager extends CacheManager {
  static const key = 'customCache';

  MyCacheManager()
      : super(
          Config(key, stalePeriod: const Duration(days: 30)),
        );
}

import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Home/data/models/app_version.dart';
import 'package:Warrior/features/Home/data/models/category_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepo = Provider<HomeRepo>((ref) {
  return HomeRepo(ref.read(dioProvider));
});

class HomeRepo {
  final Dio _dio;
  List<CategoryItem> categoryItems = [
    CategoryItem(
      title: "Muscles",
      image: AppAssets.muscles,
      navigateTo: AppRouters.muscles,
    ),
    CategoryItem(
      title: "My Workouts",
      image: AppAssets.workout,
      navigateTo: AppRouters.workouts,
    ),
    CategoryItem(
      title: "Predefined Workouts",
      image: AppAssets.dumbbell,
      navigateTo: AppRouters.predefinedWorkouts,
    ),
    // CategoryItem(
    //   title: "Supplements",
    //   image: AppAssets.supplements,
    //   navigateTo: AppRouters.supplements,
    // ),
    // CategoryItem(
    //   title: "Nutrition",
    //   image: AppAssets.nutrition,
    //   navigateTo: AppRouters.nutrition,
    // ),
  ];

  HomeRepo(this._dio);

  Future<AppVersion?> getAppVersion() async {
    try {
      final Response response = await _dio.get(ApisUrl.forceUpdate);
      if (response.statusCode == 200) {
        AppVersion appVersion =
            AppVersion.fromMap(response.data as Map<String, dynamic>);
        SharedPref.setString(StorageKeys.appVersion, appVersion.version ?? '');
        TalkerService.info(
            'App version fetched: ${appVersion.version}', 'HOME-REPO');
        return appVersion;
      }
    } catch (e) {
      TalkerService.error('Error fetching app version: $e', 'HOME-REPO');
    }
    return null;
  }
}

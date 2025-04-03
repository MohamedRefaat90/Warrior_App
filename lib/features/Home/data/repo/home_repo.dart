import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Home/data/models/category_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final homeRepo = Provider<List<CategoryItem>>((ref) {
  return categoryItems;
});

import 'package:Warrior/core/constants/assets.dart';

List<OnboardingItem> onboardingItems = [
  OnboardingItem(
      titleKey: 'onboardingTitle1',
      descriptionKey: 'onboardingDesc1',
      image: AppAssets.onboarding1),
  OnboardingItem(
      titleKey: 'onboardingTitle2',
      descriptionKey: 'onboardingDesc2',
      image: AppAssets.onboarding2),
  OnboardingItem(
      titleKey: 'onboardingTitle3',
      descriptionKey: 'onboardingDesc3',
      image: AppAssets.onboarding3),
];

class OnboardingItem {
  final String titleKey;
  final String descriptionKey;
  final String image;

  OnboardingItem(
      {required this.titleKey,
      required this.descriptionKey,
      required this.image});
}

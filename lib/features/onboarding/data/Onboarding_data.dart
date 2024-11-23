import 'package:Warrior/core/constants/assets.dart';

class onboardingitem {
  final String title;
  final String description;
  final String image;

  onboardingitem(
      {required this.title, required this.description, required this.image});
}

List<onboardingitem> onboardingitems = [
  onboardingitem(
      title: 'Target Every Muscle',
      description:
          'Unlock a variety of exercises designed for every muscle group to build strength effectively.',
      image: AppAssets.onboarding1),
  onboardingitem(
      title: 'Customize Your Workouts',
      description:
          'Craft your unique workout sets to match your fitness goals and preferences.',
      image: AppAssets.onboarding2),
  onboardingitem(
      title: 'Your Fitness, Your Way',
      description:
          'Take control of your training with a personalized approach to achieving your best self.',
      image: AppAssets.onboarding3),
];

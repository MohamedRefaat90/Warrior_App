import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart' show SharedPref;
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void checkAndShowReviewDialog(BuildContext context) {
  final numberOfWorkouts = SharedPref.getInt(StorageKeys.numberOfWorkouts) ?? 0;
  final isRating = SharedPref.getBool(StorageKeys.isRating) ?? false;
  TalkerService.warning(
    'Check Review Dialog - Number of Workouts: $numberOfWorkouts, Is Rating: $isRating',
    'HOME',
  );
  if (numberOfWorkouts == 3 && !isRating) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Enjoying Warrior?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(AppAssets.stars),
            const Text(
                'Thank you for using Warrior! Would you like to rate the app and help others discover it?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          CustomBTN(
            widget: const Text('Rate the App'),
            color: AppColors.primaryColor,
            padding: 12,
            press: () async {
              Navigator.of(context).pop();
              SharedPref.setBool(StorageKeys.isRating, true);
              if (await AppServices.inAppReview.isAvailable() && !kDebugMode) {
                await AppServices.inAppReview.requestReview();
                TalkerService.info('In-app review requested', 'HOME');
              } else {
                await AppServices.inAppReview.openStoreListing();
                TalkerService.info('Store listing opened', 'HOME');
              }
            },
          ),
        ],
      ),
    );
  }
}

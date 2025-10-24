import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Home/presentation/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';

void checkForForceUpdate(WidgetRef ref, BuildContext context) async {
  try {
    // Get the actual installed app version from pubspec.yaml
    final packageInfo = await PackageInfo.fromPlatform();
    final installedVersion = packageInfo.version;

    // Get the required version from API
    final currentAppVersion = await ref.read(homeProvider).getAppVersion();
    final isForceUpdate = currentAppVersion?.is_force_update ?? false;
    final requiredVersion = currentAppVersion?.version ?? '';

    TalkerService.info(
      'Version Check - Installed: $installedVersion, Required: $requiredVersion, Force Update: $isForceUpdate',
      'HOME',
    );

    // Compare installed version with required version
    if (installedVersion != requiredVersion &&
        isForceUpdate &&
        context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text(
              'Update Available',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(AppAssets.newUpdate),
                10.verticalSpace,
                const Text(
                  'A new version of the app is available. Please update to continue.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              CustomBTN(
                widget: const Text('Update Now'),
                color: AppColors.primaryColor,
                padding: 12,
                width: double.infinity,
                press: () async {
                  await AppServices.inAppReview.openStoreListing();
                },
              ),
            ],
          ),
        ),
      );
    }
  } catch (e) {
    TalkerService.error('Error checking for app update: $e', 'HOME');
  }
}

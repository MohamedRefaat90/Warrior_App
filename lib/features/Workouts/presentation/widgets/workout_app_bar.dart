import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Custom app bar for workout screen with flexible space and gradient background.
class WorkoutAppBar extends ConsumerWidget {
  const WorkoutAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.primaryColor,
        ),
        onPressed: () => context.goNamed(AppRouters.home),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Material(
          color: Colors.transparent,
          child: Text(
            'yourWorkouts'.tr(context),
            style: TextStyle(
              fontFamily:
                  appSettings.locale.languageCode == 'ar' ? "Cairo" : "Poppins",
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: isDark ? Colors.white : Colors.black87,
              shadows: [
                Shadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.black,
                      Colors.black.withOpacity(0.8),
                    ]
                  : [
                      Colors.grey[50]!,
                      Colors.grey[50]!.withOpacity(0.8),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/features/Home/presentation/widgets/animated_toggle_switcher.dart';
import 'package:Warrior/features/Home/presentation/widgets/language_toggle_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
          ),
          iconColor: AppColors.white,
          collapsedIconColor: AppColors.white,
          title: Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: AppColors.white,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                context.l10n.settings,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          children: [
            // Dark Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.darkMode,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const AnimatedToggleSwitcher()
              ],
            ),
            SizedBox(height: 12.h),
            // Language Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.language,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const LanguageToggleSwitcher()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

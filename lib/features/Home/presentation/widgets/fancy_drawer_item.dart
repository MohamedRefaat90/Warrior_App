import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FancyDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const FancyDrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

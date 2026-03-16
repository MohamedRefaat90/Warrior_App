import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveUtils.value<double>(
      context,
      mobile: 80,
      tablet: 100,
      desktop: 120,
    );
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(context.mediumSpacing),
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(context.responsiveBorderRadius),
              color: AppColors.white),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

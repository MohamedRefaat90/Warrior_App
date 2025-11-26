import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveUtils.value<double>(
      context,
      mobile: 25,
      tablet: 30,
      desktop: 35,
    );
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

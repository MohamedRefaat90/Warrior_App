import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 70,
        height: 70,
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 5,
        ),
      ),
    );
  }
}

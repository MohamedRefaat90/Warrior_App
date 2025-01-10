import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

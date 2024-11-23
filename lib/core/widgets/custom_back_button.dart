import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  final Color color;

  const CustomBackButton({super.key, required this.color});
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => context.pop(),
        icon: CircleAvatar(
            backgroundColor:
                color == AppColors.white ? AppColors.white : AppColors.black,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.arrow_back_ios,
                color: color == AppColors.white
                    ? AppColors.black
                    : AppColors.white,
              ),
            )));
  }
}

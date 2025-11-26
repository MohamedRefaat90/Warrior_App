import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
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
              padding: EdgeInsets.only(left: context.smallSpacing),
              child: Icon(
                Icons.arrow_back_ios,
                size: ResponsiveUtils.iconSize(context),
                color: color == AppColors.white
                    ? AppColors.black
                    : AppColors.white,
              ),
            )));
  }
}

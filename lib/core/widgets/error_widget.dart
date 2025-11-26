import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CustomErrorWidget extends StatelessWidget {
  final String errorMsg;
  const CustomErrorWidget({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: ResponsiveUtils.value<double>(
          context,
          mobile: 250,
          tablet: 300,
          desktop: 350,
        ),
        constraints: BoxConstraints(
          minHeight: ResponsiveUtils.value<double>(
            context,
            mobile: 120,
            tablet: 140,
            desktop: 160,
          ),
        ),
        alignment: Alignment.center,
        padding: context.cardPadding,
        decoration: BoxDecoration(
            color: const Color.fromARGB(209, 181, 26, 9),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius)),
        child: Text(
          errorMsg,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
              ),
        ),
      ),
    );
  }
}

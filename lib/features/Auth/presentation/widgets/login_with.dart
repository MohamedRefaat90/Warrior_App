import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';

class LoginWith extends StatelessWidget {
  const LoginWith({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDarkMode ? AppColors.white : AppColors.black,
            height: 1,
            thickness: 1,
            indent: 50,
          ),
        ),
        Text("  ${'loginWith'.tr(context)}  "),
        Expanded(
          child: Divider(
            color: isDarkMode ? AppColors.white : AppColors.black,
            height: 1,
            thickness: 1,
            endIndent: 50,
          ),
        ),
      ],
    );
  }
}

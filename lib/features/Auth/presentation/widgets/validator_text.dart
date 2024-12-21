import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ValidatorText extends StatelessWidget {
  final String title;
  final bool rule;
  final bool? displayWhen;
  const ValidatorText({
    super.key,
    required this.title,
    required this.rule,
    this.displayWhen = true,
  });
  @override
  Widget build(BuildContext context) {
    return displayWhen!
        ? Row(
            children: [
              Icon(
                rule ? Icons.done_rounded : Icons.cancel,
                size: 18,
                color: rule ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(color: rule ? AppColors.green : AppColors.red),
              ),
            ],
          )
        : const SizedBox();
  }
}

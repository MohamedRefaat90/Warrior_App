import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoToSignup extends StatelessWidget {
  const GoToSignup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('dontHaveAccount'.tr(context)),
        TextButton(
            onPressed: () => context.pushNamed(AppRouters.signup),
            style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(5))),
            child: Text(
              'signup'.tr(context),
              style: TextStyle(
                  color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            ))
      ],
    );
  }
}

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
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
        const Text("Don't have an account?"),
        TextButton(
            onPressed: () => context.pushNamed(AppRouters.signup),
            style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.all(5))),
            child: Text(
              "Sign Up",
              style: TextStyle(color: AppColors.primaryColor),
            ))
      ],
    );
  }
}

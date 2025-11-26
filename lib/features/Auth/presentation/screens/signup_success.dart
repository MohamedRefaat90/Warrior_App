import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SignupSuccess extends StatelessWidget {
  const SignupSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(AppAssets.trainer, height: 400),
            ),
            const SizedBox(height: 20),
            Text(
              'welcome warrior you can join the battle now 💪'.capitalizeWord(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins"),
            ),
            const SizedBox(height: 20),
            CustomBTN(
                widget: const Text("Login"),
                color: AppColors.primaryColor,
                padding: 15,
                width: context.screenWidth * 0.4,
                press: () => context.goNamed(AppRouters.login)),
          ],
        ),
      ),
    );
  }
}

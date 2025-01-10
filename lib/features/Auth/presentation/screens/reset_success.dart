import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ResetPasswordSuccess extends StatefulWidget {
  const ResetPasswordSuccess({super.key});

  @override
  State<ResetPasswordSuccess> createState() => _ResetPasswordSuccessState();
}

class _ResetPasswordSuccessState extends State<ResetPasswordSuccess> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () {
      context.goNamed(AppRouters.login);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Lottie.asset(AppAssets.resetSuccess,
                    repeat: false,
                    width: 200.w,
                    frameRate: const FrameRate(60))),
            Text(
              "Password reset successfully Try to login with new password"
                  .capitalizeWord(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

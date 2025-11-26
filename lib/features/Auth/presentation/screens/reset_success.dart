import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ResetPasswordSuccess extends StatefulWidget {
  const ResetPasswordSuccess({super.key});

  @override
  State<ResetPasswordSuccess> createState() => _ResetPasswordSuccessState();
}

class _ResetPasswordSuccessState extends State<ResetPasswordSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth,
          ),
          child: Padding(
            padding: context.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Lottie.asset(AppAssets.resetSuccess,
                        repeat: false,
                        width: ResponsiveUtils.value<double>(
                          context,
                          mobile: 200,
                          tablet: 250,
                          desktop: 300,
                        ),
                        frameRate: const FrameRate(60))),
                SizedBox(height: context.mediumSpacing),
                Text(
                  "Password reset successfully Try to login with new password"
                      .capitalizeWord(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () {
      context.goNamed(AppRouters.login);
    });
    super.initState();
  }
}

import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
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
                  child: Lottie.asset(AppAssets.trainer,
                      height: ResponsiveUtils.value<double>(
                        context,
                        mobile: 350,
                        tablet: 400,
                        desktop: 450,
                      )),
                ),
                SizedBox(height: context.mediumSpacing),
                Text(
                  'welcomeWarrior'.tr(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.mediumSpacing),
                CustomBTN(
                    widget: Text('login'.tr(context)),
                    color: AppColors.primaryColor,
                    padding: 15,
                    width: ResponsiveUtils.value<double>(
                      context,
                      mobile: context.screenWidth * 0.5,
                      tablet: 200,
                      desktop: 220,
                    ),
                    press: () => context.goNamed(AppRouters.login)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

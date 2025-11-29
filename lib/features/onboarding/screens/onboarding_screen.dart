import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/onboarding/data/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    final isDesktopOrTablet = context.isDesktop || context.isTablet;

    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: onboardingItems.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) => Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktopOrTablet ? 600 : double.infinity,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: ResponsiveUtils.value(
                              context,
                              mobile: context.screenHeight * 0.45,
                              tablet: context.screenHeight * 0.4,
                              desktop: context.screenHeight * 0.35,
                            ),
                          ),
                          child: Image.asset(
                            onboardingItems[index].image,
                            fit: BoxFit.contain,
                            width: ResponsiveUtils.value(
                              context,
                              mobile: context.screenWidth * 0.8,
                              tablet: context.screenWidth * 0.5,
                              desktop: 400.0,
                            ),
                          ),
                        ),
                        SizedBox(height: context.mediumSpacing),
                        Text(
                          onboardingItems[index].titleKey.tr(context),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.smallSpacing),
                        Text(
                          onboardingItems[index].descriptionKey.tr(context),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: context.largeSpacing),
            child: (currentIndex == 2)
                ? CustomBTN(
                    widget: Text('letsBegin'.tr(context)),
                    color: AppColors.black,
                    padding: ResponsiveUtils.value(context,
                        mobile: 15.0, desktop: 18.0),
                    width: ResponsiveUtils.value(
                      context,
                      mobile: context.screenWidth * 0.5,
                      tablet: 220.0,
                      desktop: 250.0,
                    ),
                    press: () async {
                      await SharedPref.setBool(StorageKeys.isFirstTime, false);
                      await SharedPref.setInt(StorageKeys.numberOfWorkouts, 0);
                      if (context.mounted) {
                        context.pushNamed(AppRouters.login);
                      }
                    })
                : SmoothPageIndicator(
                    controller: pageController,
                    count: onboardingItems.length,
                    effect: WormEffect(
                        dotColor: AppColors.black,
                        activeDotColor: AppColors.primaryColor),
                  ),
          ),
        ],
      ),
    ));
  }
}

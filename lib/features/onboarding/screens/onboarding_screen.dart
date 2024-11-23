import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/onboarding/data/Onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: onboardingitems.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    onboardingitems[index].image,
                    width: 0.8.sw,
                  ),
                  20.verticalSpace,
                  Text(
                    onboardingitems[index].title,
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  10.verticalSpace,
                  Text(
                    onboardingitems[index].description,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
        (currentIndex == 2)
            ? CustomBTN(
                widget: const Text('Let\'s Begin '),
                color: AppColors.black,
                padding: 15,
                width: 0.5.sw,
                press: () => context.goNamed(AppRouters.login))
            : SmoothPageIndicator(
                controller: pageController,
                count: onboardingitems.length,
                effect: WormEffect(
                    dotColor: AppColors.black,
                    activeDotColor: AppColors.primaryColor!),
              ),
        30.verticalSpace
      ],
    ));
  }
}

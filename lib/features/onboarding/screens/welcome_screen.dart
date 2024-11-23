import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            AppAssets.welcome,
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          SvgPicture.asset(
            AppAssets.overlay,
            fit: BoxFit.cover,
            width: double.infinity,
            colorFilter: const ColorFilter.mode(
                Color.fromARGB(65, 0, 0, 0), BlendMode.colorBurn),
          ),
          Positioned(
            bottom: 0.2.sh,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'kings',
                  ),
                  TextSpan(
                    text: 'Welcome ',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: 'Warrior\n',
                        style: TextStyle(
                          color: Colors.red[900],
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomBTN(
                  widget: const Text("Start"),
                  press: () => context.goNamed(AppRouters.onboarding),
                  padding: 15,
                  width: 150,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

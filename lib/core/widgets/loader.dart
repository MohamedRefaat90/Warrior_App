import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAssets.loader,
        width: ResponsiveUtils.value<double>(
          context,
          mobile: 120,
          tablet: 150,
          desktop: 180,
        ),
      ),
    );
  }
}

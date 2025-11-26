import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/services/google_signin.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Consumer(
      builder: (context, ref, child) => MaterialButton(
        onPressed: () async {
          String? token = await GoogleSignInService.signIn();
          ref.read(loginProvider.notifier).googleLogin(token);
        },
        minWidth: 50,
        height: 50,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isDarkMode ? AppColors.white : AppColors.black)),
        child: SvgPicture.asset(
          AppAssets.googleIcon,
          width: 20,
        ),
      ),
    );
  }
}

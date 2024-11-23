import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

class LoginWith extends StatelessWidget {
  const LoginWith({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.black,
            height: 1,
            thickness: 1,
            indent: 50,
          ),
        ),
        Text("  Login With  "),
        Expanded(
          child: Divider(
            color: AppColors.black,
            height: 1,
            thickness: 1,
            endIndent: 50,
          ),
        ),
      ],
    );
  }
}

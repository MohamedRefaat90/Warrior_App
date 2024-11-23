import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/core/widgets/text_logo.dart';
import 'package:Warrior/features/Auth/presentation/widgets/go_to_signup.dart';
import 'package:Warrior/features/Auth/presentation/widgets/google_button.dart';
import 'package:Warrior/features/Auth/presentation/widgets/login_with.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        height: 0.56.sh,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Login",
                style: TextStyle(fontFamily: "Poppins", fontSize: 30),
              ),
              20.verticalSpace,
              const CustomTextField(placeholderText: "Email"),
              10.verticalSpace,
              const CustomTextField(placeholderText: "password"),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        padding:
                            WidgetStateProperty.all(const EdgeInsets.all(5))),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.black),
                    )),
              ),
              10.verticalSpace,
              CustomBTN(
                  widget: const Text("Login"),
                  color: AppColors.primaryColor,
                  padding: 15,
                  splashColor: AppColors.black,
                  width: 0.4.sw,
                  press: () {}),
              20.verticalSpace,
              const LoginWith(),
              10.verticalSpace,
              const GoogleButton(),
              10.verticalSpace,
              const GoToSignup()
            ],
          ),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              ),
              child: Image.asset("assets/login.jpg")),
          Container(
            width: double.infinity,
            height: 0.3.sh,
            color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.5),
          ),
          Positioned(
            top: 1.0.sh / 4,
            left: 0.5.sw - 95,
            child: const TextLogo(fz: 50, letterSpacing: 5),
          )
        ],
      )),
    );
  }
}

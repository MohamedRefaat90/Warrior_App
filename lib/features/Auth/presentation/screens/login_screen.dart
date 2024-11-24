import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/core/widgets/text_logo.dart';
import 'package:Warrior/features/Auth/presentation/widgets/go_to_signup.dart';
import 'package:Warrior/features/Auth/presentation/widgets/google_button.dart';
import 'package:Warrior/features/Auth/presentation/widgets/login_with.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        height: 0.56.sh,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 30),
                ),
                15.verticalSpace,
                CustomTextField(
                    placeholderText: "Email",
                    validator: (value) => emailValidator(value!)),
                10.verticalSpace,
                CustomTextField(
                    placeholderText: "password",
                    isPassword: true,
                    validator: (value) => passwordValidator(value!)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () =>
                          context.pushNamed(AppRouters.forgetPassword),
                      style: ButtonStyle(
                          padding:
                              WidgetStateProperty.all(const EdgeInsets.all(5))),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppColors.black),
                      )),
                ),
                0.verticalSpace,
                CustomBTN(
                    widget: const Text("Login"),
                    color: AppColors.primaryColor,
                    padding: 15,
                    splashColor: AppColors.black,
                    width: 0.4.sw,
                    press: () {
                      if (formKey.currentState!.validate()) {
                        // Navigator.pushNamed(context, "/home");
                      }
                    }),
                10.verticalSpace,
                const LoginWith(),
                10.verticalSpace,
                const GoogleButton(),
                10.verticalSpace,
                const GoToSignup()
              ],
            ),
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
              child: Image.asset(
                AppAssets.loginBanar,
                color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              )),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.133,
            left: MediaQuery.of(context).size.width * 0.345,
            child: const TextLogo(fz: 30, letterSpacing: 5),
          )
        ],
      )),
    );
  }
}

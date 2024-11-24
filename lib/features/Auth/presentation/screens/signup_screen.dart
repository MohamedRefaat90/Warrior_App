import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Signup',
          style: TextStyle(fontFamily: "Poppines", fontSize: 30),
        ),
      ),
      body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20)
                .copyWith(top: 50, bottom: 20),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Column(
                  children: [
                    15.verticalSpace,
                    CustomTextField(
                        placeholderText: "Name",
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        }),
                    10.verticalSpace,
                    CustomTextField(
                        placeholderText: "Email",
                        validator: (value) => emailValidator(value!)),
                    10.verticalSpace,
                    CustomTextField(
                        placeholderText: "password",
                        textEditingController: passwordController,
                        isPassword: true,
                        validator: (value) => passwordValidator(value!)),
                    10.verticalSpace,
                    CustomTextField(
                        placeholderText: "Confirm Password",
                        isPassword: true,
                        validator: (value) => confirmPasswordValidator(
                            value!, passwordController.text)),
                    50.verticalSpace,
                    CustomBTN(
                        widget: const Text("Signup"),
                        color: AppColors.primaryColor,
                        padding: 15,
                        splashColor: AppColors.black,
                        width: 0.4.sw,
                        press: () {
                          if (formKey.currentState!.validate()) {}
                        })
                  ],
                ),
                Transform.rotate(
                  angle: 3.14 / 4,
                  child: Image.asset(
                    AppAssets.dumbbell,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                )
              ],
            ),
          )),
    );
  }
}

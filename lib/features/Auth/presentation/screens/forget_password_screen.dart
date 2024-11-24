import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
        centerTitle: true,
      ),
      body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                CustomTextField(
                    placeholderText: "Email",
                    validator: (value) => emailValidator(value!)),
                30.verticalSpace,
                CustomBTN(
                    widget: const Text("Send Email"),
                    color: AppColors.primaryColor,
                    padding: 15,
                    splashColor: AppColors.black,
                    width: 0.4.sw,
                    press: () {
                      if (formKey.currentState!.validate()) {
                        context.pushNamed(AppRouters.verifyOTP);
                      }
                    }),
              ],
            ),
          )),
    );
  }
}

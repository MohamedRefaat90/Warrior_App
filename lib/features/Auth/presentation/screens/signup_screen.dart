import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Auth/presentation/provider/auth_states.dart';
import 'package:Warrior/features/Auth/presentation/provider/signup_provider.dart';
import 'package:Warrior/features/Auth/presentation/widgets/password_validation_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routers.dart';
import '../../../../core/functions/flushbar.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthState authState = ref.watch<AuthState>(signupProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Signup',
          style: TextStyle(fontFamily: "Poppines", fontSize: 30),
        ),
      ),
      body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        textEditingController: nameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        }),
                    10.verticalSpace,
                    CustomTextField(
                        placeholderText: "Email",
                        textEditingController: emailController,
                        validator: (value) => emailValidator(value!)),
                    10.verticalSpace,
                    CustomTextField(
                      placeholderText: "password",
                      textEditingController: passwordController,
                      isPassword: true,
                      onChange: (password) => ref
                          .read(signupProvider.notifier)
                          .passwordValidator(password),
                      // validator: (value) => passwordValidator(value!)
                    ),
                    10.verticalSpace,
                    PasswordValidationRules(),
                    10.verticalSpace,
                    CustomTextField(
                        placeholderText: "Confirm Password",
                        isPassword: true,
                        validator: (value) => confirmPasswordvalidator(
                            value!, passwordController.text)),
                    50.verticalSpace,
                    CustomBTN(
                        widget: authState.isLoading
                            ? const BtnLoader()
                            : const Text("Signup"),
                        color: AppColors.primaryColor,
                        padding: 15,
                        splashColor: AppColors.black,
                        width: 0.4.sw,
                        press: () {
                          if (formKey.currentState!.validate() &&
                              validatePassword()) {
                            ref.read(signupProvider.notifier).signup(
                                email: emailController.text,
                                password: passwordController.text,
                                username: nameController.text);
                          }
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

  @override
  void initState() {
    ref.listenManual(signupProvider, (previous, current) {
      if (current.isSuccess) {
        context.goNamed(AppRouters.signupSuccess);
      } else if (current.errorMessage != null) {
        flushBar(context,
            message: current.errorMessage!, color: Colors.redAccent);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    resetFlagFields();
    super.dispose();
  }
}

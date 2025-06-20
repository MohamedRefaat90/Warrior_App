import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/functions/snakbar.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Auth/presentation/widgets/go_to_signup.dart';
import 'package:Warrior/features/Auth/presentation/widgets/google_button.dart';
import 'package:Warrior/features/Auth/presentation/widgets/login_with.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ProviderStates = ref.watch(loginProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        height: 0.66.sh,
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
                10.verticalSpace,
                CustomTextField(
                    placeholderText: "Email",
                    isObscure: false,
                    textEditingController: emailController,
                    validator: (value) => emailValidator(value!.trim())),
                10.verticalSpace,
                CustomTextField(
                    placeholderText: "password",
                    textEditingController: passwordController,
                    isPassword: true,
                    isObscure: true,
                    validator: (value) =>
                        value!.isEmpty ? "Password is required" : null),
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
                    widget: ProviderStates.isLoading
                        ? const BtnLoader()
                        : const Text("Login"),
                    color: AppColors.primaryColor,
                    padding: 15,
                    splashColor: AppColors.black,
                    width: 0.4.sw,
                    press: () async {
                      if (formKey.currentState!.validate()) {
                        await ref.read(loginProvider.notifier).login(
                            emailController.text, passwordController.text);
                      }
                    }),
                // 10.verticalSpace,
                // TextButton(
                //     onPressed: () {
                //       SharedPref.setBool(StorageKeys.isGuestMode, true);
                //       context.goNamed(AppRouters.muscles);
                //     },
                //     child: Text("Guest Mode")),
                const LoginWith(),
                10.verticalSpace,
                const GoogleButton(),
                // 10.verticalSpace,
                const GoToSignup()
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: Image.asset(
        AppAssets.loginBanar,
        fit: BoxFit.cover,
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(loginProvider, (previous, current) {
      if (current.isSuccess) {
        context.goNamed(AppRouters.home);
      } else if (current.errorMessage != null) {
        showSnackBar(
          context,
          current.errorMessage!
                  .contains("The connection errored: Failed host lookup:")
              ? "Check Your Internet Connection"
              : current.errorMessage!,
        );
      }
    });
  }
}

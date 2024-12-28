import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Auth/presentation/widgets/password_validation_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/functions/flushbar.dart';
import '../provider/reset_password_provider..dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});
  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ProviderStates providerStates = ref.watch(resetPasswordProvider);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.goNamed(AppRouters.login)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Enter your new password".capitalizeWord(),
                style: TextStyle(fontSize: 15.sp),
              ),
              20.verticalSpace,
              CustomTextField(
                  textEditingController: passwordController,
                  placeholderText: 'New Password',
                  onChange: (password) => ref
                      .read(resetPasswordProvider.notifier)
                      .passwordValidator(password),
                  // validator: (value) => passwordValidator(value ?? ""),
                  isPassword: true),
              10.verticalSpace,
              PasswordValidationRules(),
              10.verticalSpace,
              CustomTextField(
                  textEditingController: confirmPasswordController,
                  validator: (value) =>
                      confirmPasswordvalidator(value!, passwordController.text),
                  placeholderText: 'Confirm Password',
                  isPassword: true),
              20.verticalSpace,
              CustomBTN(
                  widget: providerStates.isLoading
                      ? const BtnLoader()
                      : const Text("Reset Password"),
                  color: AppColors.black,
                  padding: 15,
                  width: 0.4.sw,
                  splashColor: AppColors.primaryColor,
                  press: () async {
                    ResetPasswordNotifier resetNotifier =
                        ref.read(resetPasswordProvider.notifier);

                    if (formKey.currentState!.validate() &&
                        resetNotifier.validatePassword()) {
                      await ref
                          .read(resetPasswordProvider.notifier)
                          .resetPassword(
                              email: widget.email,
                              password: passwordController.text);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    resetFlagFields();
    super.dispose();
  }

  @override
  void initState() {
    ref.listenManual(resetPasswordProvider, (previous, current) {
      if (current.isSuccess) {
        context.goNamed(AppRouters.resetSuccess);
      } else if (current.errorMessage != null) {
        flushBar(context, message: current.errorMessage!);
      }
    });
    super.initState();
  }
}

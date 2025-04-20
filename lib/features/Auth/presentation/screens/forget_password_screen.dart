import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/provider_states.dart';
import '../provider/forgetpassword_provider.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ProviderStates = ref.watch(forgetPasswordProvider);
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
                    textEditingController: emailController,
                    isObscure: false,
                    validator: (value) => emailValidator(value!.trim())),
                30.verticalSpace,
                CustomBTN(
                    widget: ProviderStates.isLoading
                        ? const BtnLoader()
                        : const Text("Send Email"),
                    color: AppColors.primaryColor,
                    padding: 15,
                    splashColor: AppColors.black,
                    width: 0.4.sw,
                    press: () async {
                      if (formKey.currentState!.validate()) {
                        await ref
                            .read(forgetPasswordProvider.notifier)
                            .forgetPassword(emailController.text);

                        if (context.mounted) {
                          if (ProviderStates.isSuccess) {
                          } else if (ProviderStates.errorMessage != null) {
                            flushBar(context,
                                message: ProviderStates.errorMessage!);
                          }
                        }
                      }
                    }),
              ],
            ),
          )),
    );
  }

  // @override
  // void dispose() {
  //   ref.read(authProvider.notifier).resetState();
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    ref.listenManual<ProviderStates>(
      forgetPasswordProvider,
      (previous, next) {
        if (next.isSuccess) {
          context.pushNamed(AppRouters.verifyOTP,
              extra: emailController.text.toLowerCase().trim());
        }
      },
    );
  }
}

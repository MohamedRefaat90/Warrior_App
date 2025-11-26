import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final providerStates = ref.watch(forgetPasswordProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: context.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ResponsiveUtils.maxContentWidth,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                        placeholderText: "Email",
                        textEditingController: emailController,
                        isObscure: false,
                        validator: (value) => emailValidator(value!.trim())),
                    SizedBox(height: context.largeSpacing),
                    CustomBTN(
                        widget: providerStates.isLoading
                            ? const BtnLoader()
                            : const Text("Send Email"),
                        color: AppColors.primaryColor,
                        padding: 15,
                        splashColor: AppColors.black,
                        width: ResponsiveUtils.value<double>(
                          context,
                          mobile: context.screenWidth * 0.5,
                          tablet: 200,
                          desktop: 220,
                        ),
                        press: () async {
                          if (formKey.currentState!.validate()) {
                            await ref
                                .read(forgetPasswordProvider.notifier)
                                .forgetPassword(emailController.text);

                            if (context.mounted) {
                              if (providerStates.isSuccess) {
                                // Success will navigate via listener
                              } else if (providerStates.errorMessage != null) {
                                showErrorFlushbar(
                                  position: FlushbarPosition.BOTTOM,
                                  context,
                                  providerStates.errorMessage!,
                                );
                              }
                            }
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

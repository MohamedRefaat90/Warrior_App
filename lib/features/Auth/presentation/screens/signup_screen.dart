import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Auth/presentation/provider/signup_provider.dart';
import 'package:Warrior/features/Auth/presentation/widgets/password_validation_rules.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ProviderStates providerStates = ref.watch<ProviderStates>(signupProvider);
    final isDesktopOrTablet = context.isDesktop || context.isTablet;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'signup'.tr(context),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: "Poppines",
              ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding)
                .copyWith(
                    top: context.mediumSpacing, bottom: context.mediumSpacing),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.maxCardWidth + 100,
              ),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: context.smallSpacing),
                    CustomTextField(
                        placeholderText: 'name'.tr(context),
                        textEditingController: nameController,
                        isObscure: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'nameRequired'.tr(context);
                          }
                          return null;
                        }),
                    SizedBox(height: context.smallSpacing),
                    CustomTextField(
                        placeholderText: 'email'.tr(context),
                        textEditingController: emailController,
                        isObscure: false,
                        validator: (value) => emailValidator(value!.trim())),
                    SizedBox(height: context.smallSpacing),
                    CustomTextField(
                      placeholderText: 'password'.tr(context),
                      textEditingController: passwordController,
                      isObscure: true,
                      isPassword: true,
                      onChange: (password) => ref
                          .read(signupProvider.notifier)
                          .passwordValidator(password),
                    ),
                    SizedBox(height: context.smallSpacing),
                    const PasswordValidationRules(),
                    SizedBox(height: context.smallSpacing),
                    CustomTextField(
                        placeholderText: 'confirmPassword'.tr(context),
                        isObscure: true,
                        isPassword: true,
                        validator: (value) => confirmPasswordvalidator(
                            value!, passwordController.text)),
                    SizedBox(height: context.largeSpacing),
                    Center(
                      child: CustomBTN(
                          widget: providerStates.isLoading
                              ? const BtnLoader()
                              : Text('signup'.tr(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                          color: AppColors.primaryColor,
                          padding: ResponsiveUtils.value(context,
                              mobile: 15.0, desktop: 18.0),
                          splashColor: AppColors.black,
                          width: ResponsiveUtils.value(
                            context,
                            mobile: context.screenWidth * 0.4,
                            tablet: 200.0,
                            desktop: 220.0,
                          ),
                          press: () {
                            if (formKey.currentState!.validate() &&
                                validatePassword()) {
                              ref.read(signupProvider.notifier).signup(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  username: nameController.text);
                            }
                          }),
                    ),
                    if (!isDesktopOrTablet) ...[
                      SizedBox(height: context.screenHeight * 0.08),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Transform.rotate(
                          angle: 3.14 / 4,
                          child: Image.asset(
                            AppAssets.dumbbell,
                            width: context.screenWidth * 0.3,
                          ),
                        ),
                      ),
                    ],
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    resetFlagFields();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(signupProvider, (previous, current) {
      if (current.isSuccess) {
        context.goNamed(AppRouters.signupSuccess);
      } else if (current.errorMessage != null) {
        showErrorFlushbar(
          context,
          position: FlushbarPosition.BOTTOM,
          current.errorMessage!,
        );
      }
    });
  }
}

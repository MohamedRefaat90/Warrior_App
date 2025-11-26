import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Auth/presentation/widgets/go_to_signup.dart';
import 'package:Warrior/features/Auth/presentation/widgets/google_button.dart';
import 'package:Warrior/features/Auth/presentation/widgets/login_with.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isDesktopOrTablet = context.isDesktop || context.isTablet;

    // For desktop/tablet, use a different layout approach
    if (isDesktopOrTablet) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              // Left side - banner image
              Expanded(
                flex: 1,
                child: Image.asset(
                  AppAssets.loginBanar,
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
              // Right side - login form
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                    padding: context.screenPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveUtils.maxCardWidth + 100,
                      ),
                      child: _buildLoginForm(ProviderStates),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile layout with bottom sheet
    final bottomSheetHeight = context.screenHeight * 0.66;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        height: bottomSheetHeight,
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: context.smallSpacing,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.maxCardWidth + 100,
              ),
              child: _buildLoginForm(ProviderStates),
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
        showErrorFlushbar(
          position: FlushbarPosition.BOTTOM,
          context,
          current.errorMessage!
                  .contains("The connection errored: Failed host lookup:")
              ? "Check Your Internet Connection"
              : current.errorMessage!,
        );
      }
    });
  }

  Widget _buildLoginForm(dynamic providerStates) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Login",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontFamily: "Poppins")),
          SizedBox(height: context.smallSpacing),
          CustomTextField(
              placeholderText: "Email",
              isObscure: false,
              textEditingController: emailController,
              validator: (value) => emailValidator(value!.trim())),
          SizedBox(height: context.smallSpacing),
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
                onPressed: () => context.pushNamed(AppRouters.forgetPassword),
                style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.all(5))),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: AppColors.black),
                )),
          ),
          CustomBTN(
              widget: providerStates.isLoading
                  ? const BtnLoader()
                  : const Text("Login"),
              color: AppColors.primaryColor,
              padding:
                  ResponsiveUtils.value(context, mobile: 15.0, desktop: 18.0),
              splashColor: AppColors.black,
              width: ResponsiveUtils.value(
                context,
                mobile: context.screenWidth * 0.4,
                tablet: 200.0,
                desktop: 220.0,
              ),
              press: () async {
                if (formKey.currentState!.validate()) {
                  await ref
                      .read(loginProvider.notifier)
                      .login(emailController.text, passwordController.text);
                }
              }),
          SizedBox(height: context.mediumSpacing),
          const LoginWith(),
          SizedBox(height: context.mediumSpacing),
          const GoogleButton(),
          const GoToSignup()
        ],
      ),
    );
  }
}

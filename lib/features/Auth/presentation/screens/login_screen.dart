import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
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
    final providerStates = ref.watch(loginProvider);
    final isDesktopOrTablet = context.isDesktop || context.isTablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      child: _buildLoginForm(providerStates, isDark),
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
    final bottomSheetHeight = context.screenHeight * 0.60;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        height: bottomSheetHeight,
        color: isDark ? AppColors.darkBackground : Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: context.smallSpacing,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxCardWidth + 100,
          ),
          child: _buildLoginForm(providerStates, isDark),
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
              ? 'checkInternetConnection'.tr(context)
              : current.errorMessage!,
        );
      }
    });
  }

  Widget _buildLoginForm(dynamic providerStates, bool isDark) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.smallSpacing * 2),
          Text('login'.tr(context),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily:
                      ref.watch(appSettingsProvider.notifier).fontFamily(),
                  color: isDark ? AppColors.white : AppColors.black)),
          SizedBox(height: context.smallSpacing * 4),
          CustomTextField(
              placeholderText: 'email'.tr(context),
              isObscure: false,
              textEditingController: emailController,
              validator: (value) => emailValidator(value!.trim())),
          SizedBox(height: context.smallSpacing),
          CustomTextField(
              placeholderText: 'password'.tr(context),
              textEditingController: passwordController,
              isPassword: true,
              isObscure: true,
              validator: (value) =>
                  value!.isEmpty ? 'passwordRequired'.tr(context) : null),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: () => context.pushNamed(AppRouters.forgetPassword),
                style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.all(5))),
                child: Text(
                  'forgotPassword'.tr(context),
                  style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.bold),
                )),
          ),
          CustomBTN(
              widget: providerStates.isLoading
                  ? const BtnLoader()
                  : Text('login'.tr(context),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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

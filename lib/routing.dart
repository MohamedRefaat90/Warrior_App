import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Auth/presentation/screens/signup_success.dart';
import 'package:Warrior/core/functions/custom_transition_page.dart';
import 'package:Warrior/features/Auth/presentation/screens/forget_password_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/login_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/reset_password_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/reset_success.dart';
import 'package:Warrior/features/Auth/presentation/screens/signup_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/verify_otp_screen.dart';
import 'package:Warrior/features/home/presentation/screen/home_screen.dart';
import 'package:Warrior/features/onboarding/screens/onboarding_screen.dart';
import 'package:Warrior/features/onboarding/screens/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

final GoRouter router =
    GoRouter(initialLocation: AppRouters.signupSuccess, routes: [
  GoRoute(
    path: AppRouters.welcome,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: AppRouters.onboarding,
    name: AppRouters.onboarding,
    pageBuilder: (context, state) => CustomTransition(
      child: const OnboardingScreen(),
      transitionType: PageTransitionType.fade,
    ),
  ),
  GoRoute(
    path: AppRouters.login,
    name: AppRouters.login,
    pageBuilder: (context, state) => CustomTransition(
      child: const LoginScreen(),
      transitionType: PageTransitionType.fade,
    ),
  ),
  GoRoute(
    path: AppRouters.signup,
    name: AppRouters.signup,
    pageBuilder: (context, state) => CustomTransition(
      child: const SignupScreen(),
      transitionType: PageTransitionType.bottomToTop,
    ),
  ),
  GoRoute(
    path: AppRouters.signupSuccess,
    name: AppRouters.signupSuccess,
    pageBuilder: (context, state) => CustomTransition(
      child: const SignupSuccess(),
      transitionType: PageTransitionType.bottomToTop,
    ),
  ),
  GoRoute(
    path: AppRouters.forgetPassword,
    name: AppRouters.forgetPassword,
    pageBuilder: (context, state) => CustomTransition(
      child: const ForgetPasswordScreen(),
      transitionType: PageTransitionType.rightToLeft,
    ),
  ),
  GoRoute(
    path: AppRouters.verifyOTP,
    name: AppRouters.verifyOTP,
    pageBuilder: (context, state) => CustomTransition(
      child: VerifyOtpScreen(email: state.extra! as String),
      transitionType: PageTransitionType.rightToLeft,
    ),
  ),
  GoRoute(
    path: AppRouters.newPassword,
    name: AppRouters.newPassword,
    pageBuilder: (context, state) => CustomTransition(
      child: ResetPasswordScreen(email: state.extra! as String),
      transitionType: PageTransitionType.bottomToTop,
    ),
  ),
  GoRoute(
    path: AppRouters.resetSuccess,
    name: AppRouters.resetSuccess,
    pageBuilder: (context, state) => CustomTransition(
      child: const ResetPasswordSuccess(),
      transitionType: PageTransitionType.bottomToTop,
    ),
  ),
  GoRoute(
    path: AppRouters.home,
    name: AppRouters.home,
    pageBuilder: (context, state) => CustomTransition(
      child: const HomeScreen(),
      transitionType: PageTransitionType.rightToLeft,
    ),
  ),
]);

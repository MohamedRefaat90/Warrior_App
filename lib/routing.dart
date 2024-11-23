import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/custom_transition_page.dart';
import 'package:Warrior/features/Auth/presentation/screens/login_screen.dart';
import 'package:Warrior/features/onboarding/screens/Onboarding_screen.dart';
import 'package:Warrior/features/onboarding/screens/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

final GoRouter router = GoRouter(initialLocation: AppRouters.welcome, routes: [
  GoRoute(
    path: AppRouters.welcome,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: AppRouters.onboarding,
    name: AppRouters.onboarding,
    pageBuilder: (context, state) => CustomTransition(
      child: OnboardingScreen(),
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
]);

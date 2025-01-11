import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/custom_transition_page.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/features/Auth/presentation/screens/forget_password_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/login_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/reset_password_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/reset_success.dart';
import 'package:Warrior/features/Auth/presentation/screens/signup_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/signup_success.dart';
import 'package:Warrior/features/Auth/presentation/screens/verify_otp_screen.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/screens/exercise_details_screen.dart';
import 'package:Warrior/features/Exercises/presentation/screens/exercises_screen.dart';
import 'package:Warrior/features/Exercises/presentation/screens/muscles_screen.dart';
import 'package:Warrior/features/Home/presentation/screen/home_screen.dart';
import 'package:Warrior/features/Nutrition/presentation/screens/nutrition_screen.dart';
import 'package:Warrior/features/Supplements/presentation/screens/supplements_screen.dart';
import 'package:Warrior/features/Workouts/presentation/screens/workouts_screen.dart';
import 'package:Warrior/features/onboarding/screens/onboarding_screen.dart';
import 'package:Warrior/features/onboarding/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

final GoRouter router = GoRouter(
    initialLocation: AppRouters.welcome,
    redirect: (context, state) async {
      try {
        // Retrieve values from secure storage
        String? token = await SecureStorageHandler.read(key: 'Token');
        String? isFirstTime =
            await SecureStorageHandler.read(key: 'isFirstTime');
        String currentLocation = state.matchedLocation;

        debugPrint("Current Location : $currentLocation");
        // Allow navigation to onboarding screen without redirection
        if (currentLocation == AppRouters.onboarding) {
          return null; // Do not redirect
        }
        // Handle first-time user
        if (isFirstTime == null && currentLocation != AppRouters.welcome) {
          debugPrint('First-time user, redirecting to welcome');
          return AppRouters.welcome;
        }

        // Handle logged-in user
        if (token != null &&
            isFirstTime!.isNotEmpty &&
            currentLocation != AppRouters.home) {
          return AppRouters.home;
        }

        // Handle logged-out user
        if (token == null &&
            isFirstTime!.isNotEmpty &&
            currentLocation != AppRouters.login) {
          return AppRouters.login;
        }

        // Default case
        return null;
      } catch (e) {
        debugPrint('Error in redirect logic: $e');
        return AppRouters.login; // Fallback to login on error
      }
    },
    routes: [
      GoRoute(
        path: AppRouters.welcome,
        builder: (context, state) =>
            const WelcomeScreen(key: ValueKey('WelcomeScreen')),
      ),
      GoRoute(
        path: AppRouters.onboarding,
        name: AppRouters.onboarding,
        pageBuilder: (context, state) => CustomTransition(
          child: const OnboardingScreen(key: ValueKey('OnboardingScreen')),
          transitionType: PageTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRouters.login,
        name: AppRouters.login,
        pageBuilder: (context, state) => CustomTransition(
          child: const LoginScreen(key: ValueKey('LoginScreen')),
          transitionType: PageTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRouters.signup,
        name: AppRouters.signup,
        pageBuilder: (context, state) => CustomTransition(
          child: const SignupScreen(key: ValueKey('SignupScreen')),
          transitionType: PageTransitionType.bottomToTop,
        ),
      ),
      GoRoute(
        path: AppRouters.signupSuccess,
        name: AppRouters.signupSuccess,
        pageBuilder: (context, state) => CustomTransition(
          child: const SignupSuccess(key: ValueKey('SignupSuccess')),
          transitionType: PageTransitionType.bottomToTop,
        ),
      ),
      GoRoute(
        path: AppRouters.forgetPassword,
        name: AppRouters.forgetPassword,
        pageBuilder: (context, state) => CustomTransition(
          child:
              const ForgetPasswordScreen(key: ValueKey('ForgetPasswordScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.verifyOTP,
        name: AppRouters.verifyOTP,
        pageBuilder: (context, state) => CustomTransition(
          child: VerifyOtpScreen(
              key: ValueKey('VerifyOtpScreen'), email: state.extra! as String),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.newPassword,
        name: AppRouters.newPassword,
        pageBuilder: (context, state) => CustomTransition(
          child: ResetPasswordScreen(
              key: ValueKey('ResetPasswordScreen'),
              email: state.extra! as String),
          transitionType: PageTransitionType.bottomToTop,
        ),
      ),
      GoRoute(
        path: AppRouters.resetSuccess,
        name: AppRouters.resetSuccess,
        pageBuilder: (context, state) => CustomTransition(
          child:
              const ResetPasswordSuccess(key: ValueKey('ResetPasswordSuccess')),
          transitionType: PageTransitionType.bottomToTop,
        ),
      ),
      GoRoute(
        path: AppRouters.home,
        name: AppRouters.home,
        pageBuilder: (context, state) => CustomTransition(
          child: const HomeScreen(key: ValueKey('HomeScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.muscles,
        name: AppRouters.muscles,
        pageBuilder: (context, state) => CustomTransition(
          child: const MusclesScreen(key: ValueKey('MusclesScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.exercises,
        name: AppRouters.exercises,
        pageBuilder: (context, state) => CustomTransition(
          child: ExercisesScreen(
              muscle: state.extra as Map, key: ValueKey('ExercisesScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.exerciseDetails,
        name: AppRouters.exerciseDetails,
        pageBuilder: (context, state) => CustomTransition(
          child: ExerciseDetailsScreen(
              key: ValueKey('ExerciseDetailsScreen'),
              exercise: state.extra as ExerciseModel),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.workouts,
        name: AppRouters.workouts,
        pageBuilder: (context, state) => CustomTransition(
          child: const WorkoutScreen(key: ValueKey('WorkoutScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.supplements,
        name: AppRouters.supplements,
        pageBuilder: (context, state) => CustomTransition(
          child: const SupplementsScreen(key: ValueKey('SupplementsScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
      GoRoute(
        path: AppRouters.nutrition,
        name: AppRouters.nutrition,
        pageBuilder: (context, state) => CustomTransition(
          child: const NutritionScreen(key: ValueKey('NutritionScreen')),
          transitionType: PageTransitionType.rightToLeft,
        ),
      ),
    ]);

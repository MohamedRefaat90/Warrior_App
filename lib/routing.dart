import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/secure_storage_key.dart';
import 'package:Warrior/core/functions/custom_transition_page.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart';
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
import 'package:Warrior/features/Home/presentation/screens/home_screen.dart';
import 'package:Warrior/features/Nutrition/presentation/screens/nutrition_screen.dart';
import 'package:Warrior/features/Supplements/presentation/screens/supplements_screen.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/screens/workout_details.dart';
import 'package:Warrior/features/Workouts/presentation/screens/workouts_screen.dart';
import 'package:Warrior/features/onboarding/screens/onboarding_screen.dart';
import 'package:Warrior/features/onboarding/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

class RoutersManager {
  static final GoRouter router =
      GoRouter(initialLocation: AppServices.initialLocation, routes: [
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
    GoRoute(
      path: AppRouters.muscles,
      name: AppRouters.muscles,
      pageBuilder: (context, state) => CustomTransition(
        child: MusclesScreen(
            isComingFromWorkoutScreen: (state.extra as bool?) ?? false),
        transitionType: PageTransitionType.rightToLeft,
      ),
    ),
    GoRoute(
      path: AppRouters.exercises,
      name: AppRouters.exercises,
      pageBuilder: (context, state) {
        final Map extraData = state.extra as Map;
        return CustomTransition(
          child: ExercisesScreen(
            muscle: extraData,
            isComingFromWorkoutScreen: extraData['isComingFromWorkoutScreen'],
          ),
          transitionType: PageTransitionType.rightToLeft,
        );
      },
    ),
    GoRoute(
      path: AppRouters.exerciseDetails,
      name: AppRouters.exerciseDetails,
      pageBuilder: (context, state) => CustomTransition(
        child: ExerciseDetailsScreen(exercise: state.extra as ExerciseModel),
        transitionType: PageTransitionType.rightToLeft,
      ),
    ),
    GoRoute(
      path: AppRouters.workouts,
      name: AppRouters.workouts,
      pageBuilder: (context, state) => CustomTransition(
        child: const WorkoutScreen(),
        transitionType: PageTransitionType.rightToLeft,
      ),
    ),
    GoRoute(
      path: AppRouters.workoutDetails,
      name: AppRouters.workoutDetails,
      pageBuilder: (context, state) => CustomTransition(
        child: WorkoutDetails(state.extra as WorkoutSetModel),
        transitionType: PageTransitionType.rightToLeft,
      ),
    ),
    GoRoute(
      path: AppRouters.supplements,
      name: AppRouters.supplements,
      pageBuilder: (context, state) => CustomTransition(
        child: const SupplementsScreen(),
        transitionType: PageTransitionType.rightToLeft,
      ),
    ),
    GoRoute(
      path: AppRouters.nutrition,
      name: AppRouters.nutrition,
      pageBuilder: (context, state) => CustomTransition(
        child: const NutritionScreen(),
        transitionType: PageTransitionType.rightToLeft,
      ),
    ),
  ]);

  static Future<String?> routingChecker() async {
    String? token = await SecureStorageHandler.read(key: StorageKeys.token);
    bool? isFirstTime = SharedPref.getBool(StorageKeys.isFirstTime);
    try {
      // Handle first-time user
      if (isFirstTime == null) {
        debugPrint('First-time user, redirecting to welcome');
        return AppRouters.welcome;
      }

      // Handle logged-in user
      if (token != null && isFirstTime == false) {
        return AppRouters.home;
      }

      // Handle logged-out user
      if (token == null && isFirstTime == false) {
        return AppRouters.login;
      }

      // Default case
      return null;
    } catch (e) {
      debugPrint('Error in redirect logic: $e');
      return AppRouters.login; // Fallback to login on error
    }
  }
}

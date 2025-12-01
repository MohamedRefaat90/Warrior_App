import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/functions/custom_transition_page.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/presentation/screens/forget_password_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/login_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/reset_password_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/reset_success.dart';
import 'package:Warrior/features/Auth/presentation/screens/signup_screen.dart';
import 'package:Warrior/features/Auth/presentation/screens/signup_success.dart';
import 'package:Warrior/features/Auth/presentation/screens/verify_otp_screen.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/screens/calories_calculator_screen.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/screens/calories_results_screen.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/screens/exercise_details_screen.dart';
import 'package:Warrior/features/Exercises/presentation/screens/exercises_screen.dart';
import 'package:Warrior/features/Exercises/presentation/screens/muscles_screen.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/advanced_search_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/barcode_scanner_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/favorites_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/food_search_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/nutrition_guide_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/ocr_scanner_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/product_comparison_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/product_details_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/product_form_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/search_history_screen.dart';
import 'package:Warrior/features/Home/presentation/screen/home_screen.dart';
import 'package:Warrior/features/Nutrition/presentation/screens/nutrition_screen.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/screen/predefined_workout_details.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/screen/predefined_workout_screen.dart';
import 'package:Warrior/features/Supplements/presentation/screens/supplements_screen.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/screens/shared_workout_import_screen.dart';
import 'package:Warrior/features/Workouts/presentation/screens/workout_details.dart';
import 'package:Warrior/features/Workouts/presentation/screens/workouts_screen.dart';
import 'package:Warrior/features/onboarding/screens/onboarding_screen.dart';
import 'package:Warrior/features/onboarding/screens/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:talker_flutter/talker_flutter.dart';

class RoutersManager {
  static final GoRouter router =
      GoRouter(initialLocation: AppServices.initialLocation, observers: [
    TalkerRouteObserver(TalkerService.instance)
  ], routes: [
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
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.verifyOTP,
      name: AppRouters.verifyOTP,
      pageBuilder: (context, state) => CustomTransition(
        child: VerifyOtpScreen(email: state.extra! as String),
        transitionType: PageTransitionType.fade,
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
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.muscles,
      name: AppRouters.muscles,
      pageBuilder: (context, state) => CustomTransition(
        child: MusclesScreen(
          isComingFromWorkoutScreen:
              (state.extra as Map?)?['isComingFromWorkoutScreen'] ?? false,
          appendToExistingWorkoutSet:
              (state.extra as Map?)?['appendToExistingWorkoutSet'] ?? false,
        ),
        transitionType: PageTransitionType.fade,
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
          transitionType: PageTransitionType.fade,
        );
      },
    ),
    GoRoute(
      path: AppRouters.exerciseDetails,
      name: AppRouters.exerciseDetails,
      pageBuilder: (context, state) => CustomTransition(
        child: ExerciseDetailsScreen(exercise: state.extra as ExerciseModel),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.workouts,
      name: AppRouters.workouts,
      pageBuilder: (context, state) => CustomTransition(
        child: const WorkoutScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.workoutDetails,
      name: AppRouters.workoutDetails,
      pageBuilder: (context, state) => CustomTransition(
        child: WorkoutDetails(state.extra as WorkoutSetModel),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: '/w/:code',
      name: 'shared-workout',
      redirect: (context, state) async {
        // Check if user is logged in
        final token = await SecureStorageHandler.read(key: StorageKeys.token);
        final code = state.pathParameters['code'];

        // If not logged in, redirect to login with the code stored
        if (token == null || token.isEmpty) {
          // Store the code to redirect after login
          await SharedPref.setString('pending_shared_workout', code ?? '');
          return AppRouters.login;
        }

        // User is logged in, allow access
        return null;
      },
      pageBuilder: (context, state) => CustomTransition(
        child: SharedWorkoutImportScreen(
          code: state.pathParameters['code']!,
        ),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.predefinedWorkouts,
      name: AppRouters.predefinedWorkouts,
      pageBuilder: (context, state) => CustomTransition(
        child: const PredefinedWorkoutsScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.predefinedWorkoutDetails,
      name: AppRouters.predefinedWorkoutDetails,
      pageBuilder: (context, state) => CustomTransition(
        child: PredefinedWorkoutDetails(state.extra as WorkoutSetModel),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.supplements,
      name: AppRouters.supplements,
      pageBuilder: (context, state) => CustomTransition(
        child: const SupplementsScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.nutrition,
      name: AppRouters.nutrition,
      pageBuilder: (context, state) => CustomTransition(
        child: const NutritionScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.caloriesCalculator,
      name: AppRouters.caloriesCalculator,
      pageBuilder: (context, state) => CustomTransition(
        child: const CaloriesCalculatorScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.caloriesResults,
      name: AppRouters.caloriesResults,
      pageBuilder: (context, state) => CustomTransition(
        child: const CaloriesResultsScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.foodSearch,
      name: AppRouters.foodSearch,
      pageBuilder: (context, state) => CustomTransition(
        child: const FoodSearchScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.barcodeScanner,
      name: AppRouters.barcodeScanner,
      pageBuilder: (context, state) => CustomTransition(
        child: const BarcodeScannerScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.productDetails,
      name: AppRouters.productDetails,
      pageBuilder: (context, state) => CustomTransition(
        child: ProductDetailsScreen(product: state.extra as FoodProductModel),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.advancedSearch,
      name: AppRouters.advancedSearch,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialQuery = extra?['query'] as String?;
        return CustomTransition(
          child: AdvancedSearchScreen(initialQuery: initialQuery),
          transitionType: PageTransitionType.fade,
        );
      },
    ),
    GoRoute(
      path: AppRouters.favorites,
      name: AppRouters.favorites,
      pageBuilder: (context, state) => CustomTransition(
        child: const FavoritesScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.searchHistory,
      name: AppRouters.searchHistory,
      pageBuilder: (context, state) => CustomTransition(
        child: const SearchHistoryScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.productComparison,
      name: AppRouters.productComparison,
      pageBuilder: (context, state) => CustomTransition(
        child: const ProductComparisonScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.productForm,
      name: AppRouters.productForm,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CustomTransition(
          child: ProductFormScreen(
            product: extra?['product'] as FoodProductModel?,
            barcode: extra?['barcode'] as String?,
          ),
          transitionType: PageTransitionType.fade,
        );
      },
    ),
    GoRoute(
      path: AppRouters.nutritionGuide,
      name: AppRouters.nutritionGuide,
      pageBuilder: (context, state) => CustomTransition(
        child: const NutritionGuideScreen(),
        transitionType: PageTransitionType.fade,
      ),
    ),
    GoRoute(
      path: AppRouters.ocrScanner,
      name: AppRouters.ocrScanner,
      pageBuilder: (context, state) => CustomTransition(
        child: const OcrScannerScreen(),
        transitionType: PageTransitionType.bottomToTop,
      ),
    ),
  ]);

  static Future<String?> routingChecker() async {
    String? token = await SecureStorageHandler.read(key: StorageKeys.token);
    bool? isFirstTime = SharedPref.getBool(StorageKeys.isFirstTime);
    try {
      // Handle first-time user
      if (isFirstTime == null) {
        TalkerService.info(
            'First-time user, redirecting to welcome', 'ROUTING');
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
      TalkerService.error('Error in redirect logic', 'ROUTING', e);
      return AppRouters.login; // Fallback to login on error
    }
  }
}

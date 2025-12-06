import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/network/api_error_handler.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/add_workout.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider family to fetch a shared workout by code
final sharedWorkoutProvider =
    FutureProvider.family<WorkoutSetModel, String>((ref, code) async {
  return ref.watch(workoutRepo).fetchSharedWorkout(code);
});

class SharedWorkoutImportScreen extends ConsumerWidget {
  final String code;
  const SharedWorkoutImportScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedWorkoutAsync = ref.watch(sharedWorkoutProvider(code));
    final workoutNotifier = ref.read(workoutsProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop == false) {
          // Navigate to home instead of popping (prevents app close)
          context.go(AppRouters.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to home instead of popping
              context.go(AppRouters.home);
            },
          ),
          title: sharedWorkoutAsync.when(
            data: (workout) => Text(
              workout.name!.capitalizeWord(),
              style: const TextStyle(
                fontFamily: "Kings",
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            error: (_, __) => null,
            loading: () => null,
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: sharedWorkoutAsync.when(
          data: (workout) =>
              AddWorkoutBtn(workout: workout, workoutNotifier: workoutNotifier),
          loading: () => null,
          error: (_, __) => null,
        ),
        body: sharedWorkoutAsync.when(
          data: (workout) => _WorkoutContent(workout: workout),
          loading: () => const Center(child: Loader()),
          error: (error, stack) {
            // Extract error message from ErrorHandler
            String errorMessage = 'Something went wrong'.capitalizeWord();
            if (error is ErrorHandler) {
              errorMessage = error.apiErrorModel.message ?? errorMessage;
            }

            return _ErrorView(
              onRetry: () => ref.invalidate(sharedWorkoutProvider(code)),
              errorMessage: errorMessage,
            );
          },
          skipLoadingOnRefresh: false,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String errorMessage;

  const _ErrorView({
    required this.onRetry,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again'.capitalizeWord(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            CustomBTN(
              widget: Text('retry'.tr(context)),
              width: 150,
              padding: 10,
              radius: 8,
              color: AppColors.primaryColor,
              press: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutContent extends StatelessWidget {
  final WorkoutSetModel workout;

  const _WorkoutContent({required this.workout});

  @override
  Widget build(BuildContext context) {
    // Check if workout has no exercises
    if (workout.workoutItems == null || workout.workoutItems!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No exercises in this workout'.capitalizeWord(),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const BannerAdWidget(
            adUnitId: "ca-app-pub-7417773148722475/1350605065"),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Exercise grid view
                  GridView.builder(
                    itemCount: workout.workoutItems!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getGridColumns(context),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final WorkoutItemModel workoutExercise =
                          workout.workoutItems![index];
                      return ExerciseCard(
                        exercise: workoutExercise.exercise,
                        isComingFromWorkoutScreen: false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

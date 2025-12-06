import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/localization/muscle_translations.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/download_progress_indicator.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercises_gridview.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExercisesScreen extends ConsumerWidget {
  final Map muscle;
  final bool? isComingFromWorkoutScreen;

  const ExercisesScreen({
    super.key,
    required this.muscle,
    this.isComingFromWorkoutScreen,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translatedMuscleName = translateMuscleName(context, muscle['name']);
    final appSettings = ref.watch(appSettingsProvider);
    final appSettingsNotifier = ref.watch(appSettingsProvider.notifier);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Reset select mode when navigating back using device back button
        if (didPop && (isComingFromWorkoutScreen ?? false)) {
          ref.read(workoutsProvider.notifier).selectMode = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                ref.read(workoutsProvider.notifier).selectMode = false;
                context.pop();
              },
              icon: const Icon(Icons.arrow_back_ios_new)),
          title: Text(
            appSettings.locale.languageCode == "ar"
                ? 'تمارين $translatedMuscleName'
                : '$translatedMuscleName Exercises',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: appSettingsNotifier.fontFamily(),
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ConnectivityChecker.isOnline!
            ? ref.watch(muscleExerciseProvider(muscle['id'])).when(
                loading: () => const Loader(),
                data: (exercises) {
                  // Exercises are already being cached from muscles screen
                  // Just display them
                  return Stack(
                    children: [
                      ExercisesGridView(
                        exercises: exercises,
                        isComingFromWorkoutScreen:
                            isComingFromWorkoutScreen ?? false,
                      ),
                      // Keep indicator to show ongoing cache progress
                      const DownloadProgressIndicator(),
                    ],
                  );
                },
                error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Something went wrong!'),
                          ElevatedButton(
                            onPressed: () => ref
                                .refresh(muscleExerciseProvider(muscle['id'])),
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    ))
            : HiveManager.exercisesBox.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: ResponsiveUtils.iconSize(context,
                              mobile: 64, tablet: 80, desktop: 96),
                          color: Colors.grey,
                        ),
                        SizedBox(height: context.mediumSpacing),
                        Text(
                          "No exercises available offline",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.smallSpacing),
                        Text(
                          "Please go online to download exercises",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontFamily: "poppins",
                                  color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _OfflineExercisesView(
                    muscle: muscle,
                    isComingFromWorkoutScreen:
                        isComingFromWorkoutScreen ?? false,
                  ),
      ),
    );
  }
}

class _OfflineExercisesView extends ConsumerWidget {
  final Map muscle;
  final bool isComingFromWorkoutScreen;

  const _OfflineExercisesView({
    required this.muscle,
    required this.isComingFromWorkoutScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExercises = HiveManager.exercisesBox.values
        .where((exercise) => exercise.muscleID == muscle['id'])
        .toList();

    if (filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: ResponsiveUtils.iconSize(context,
                  mobile: 64, tablet: 80, desktop: 96),
              color: Colors.grey,
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              "No ${muscle['name']} exercises available offline",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: "poppins", fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Go online to get ${muscle['name']} exercises",
              style: TextStyle(
                  fontFamily: "poppins", fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ExercisesGridView(
      exercises: filteredExercises,
      isComingFromWorkoutScreen: isComingFromWorkoutScreen,
    );
  }
}

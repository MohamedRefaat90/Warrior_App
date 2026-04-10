import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workout_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class WorkoutDetails extends ConsumerWidget {
  final WorkoutSetModel workout;

  const WorkoutDetails(this.workout, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(workoutsProvider);
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    final appSettings = ref.watch(appSettingsProvider.notifier);
    // Always look up the latest version from workoutList so the UI reflects
    // changes made via updateWorkoutSet (e.g. adding exercises).
    // For online workouts: match by server ID.
    // For offline workouts: match by createdAt (name is mutable).
    final updatedWorkout = workoutNotifier.workoutList
            .where((w) => w == workout)
            .firstOrNull ??
        workout;

    return PopScope(
      onPopInvokedWithResult: (result, data) {
        ref.watch(workoutsProvider.notifier).selectMode = false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              // Create a proper copy of the workout with existing exercises
              workoutNotifier.newWorkout = WorkoutSetModel(
                id: updatedWorkout.id,
                name: updatedWorkout.name,
                description: updatedWorkout.description,
                createdAt: updatedWorkout.createdAt,
                updatedAt: updatedWorkout.updatedAt,
                workoutItems: updatedWorkout.workoutItems != null
                    ? List<WorkoutItemModel>.from(updatedWorkout.workoutItems!)
                    : [],
              );

              context.pushNamed(AppRouters.muscles, extra: {
                "isComingFromWorkoutScreen": true,
                "appendToExistingWorkoutSet": true
              });
            },
            tooltip: context.l10n.addNewExercise,
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              color: AppColors.white,
            )),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              workoutNotifier.selectMode = false;
              Navigator.pop(context);
            },
          ),
          title: Text(
            '${updatedWorkout.name}',
            style: TextStyle(
                fontFamily: appSettings.fontFamily(),
                fontSize: context.screenWidth * 0.06,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: context.l10n.shareWorkout,
              icon: const Icon(Icons.share),
              onPressed: () async {
                try {
                  final url = await ref
                      .read(workoutRepo)
                      .createShareLink(updatedWorkout);
                  await SharePlus.instance
                      .share(ShareParams(text: 'Check out my workout: $url'));
                } catch (e) {
                  // No toast util here; keep silent or add your preferred UX.
                  TalkerService.error('Error sharing workout',
                      'WORKOUT_DETAILS', e, StackTrace.current);
                }
              },
            ),
          ],
        ),
        bottomNavigationBar: workoutNotifier.selectMode
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CustomBTN(
                  widget: Text('delete'.tr(context)),
                  color: AppColors.primaryColor,
                  press: () {
                    if (workoutNotifier.newWorkout.workoutItems == null ||
                        updatedWorkout.workoutItems == null) {
                      return;
                    }

                    Set<int> selectedExerciseIds = workoutNotifier
                        .newWorkout.workoutItems!
                        .map((e) => e.exercise.id)
                        .toSet();

                    // Both modify the local instance for immediate UI update
                    // and create the list for the API update
                    updatedWorkout.workoutItems!.removeWhere((element) =>
                        selectedExerciseIds.contains(element.exercise.id));

                    // Update the workout in the backend
                    workoutNotifier.updateWorkoutSet(WorkoutSetModel(
                      id: updatedWorkout.id,
                      name: updatedWorkout.name,
                      description: updatedWorkout.description,
                      workoutItems: updatedWorkout.workoutItems,
                    ));

                    // Explicitly disable selection mode and clear all selections
                    workoutNotifier.disableSelectMode();
                  },
                ),
              )
            : null,
        body: Column(
          children: [
            const BannerAdWidget(
                adUnitId: "ca-app-pub-7417773148722475/6577498120"),
            Expanded(child: WorkoutGridView(updatedWorkout)),
          ],
        ),
      ),
    );
  }
}

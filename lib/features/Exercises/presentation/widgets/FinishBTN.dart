import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FinishBTN extends ConsumerWidget {
  final Color primaryColor;

  final bool? appendToExistingWorkoutSet;
  const FinishBTN({
    super.key,
    required this.primaryColor,
    required this.appendToExistingWorkoutSet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    final workoutProviderState = ref.watch(workoutsProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (workoutNotifier.newWorkout.workoutItems == null ||
                  workoutNotifier.newWorkout.workoutItems!.isEmpty)
              ? null
              : () async {
                  if (!appendToExistingWorkoutSet!) {
                    // Save workout name before creating
                    final workoutName =
                        workoutNotifier.newWorkout.name ?? 'Workout';

                    await workoutNotifier.createWorkoutSet();

                    if (context.mounted) {
                      // Show success message before navigation
                      showSuccessFlushbar(
                        context,
                        position: FlushbarPosition.TOP,
                        'Workout ($workoutName) added successfully!'
                            .capitalizeWord(),
                      );

                      // Small delay to ensure message is visible before navigation
                      await Future.delayed(const Duration(milliseconds: 1200));

                      if (context.mounted) {
                        context.go(AppRouters.workouts);
                      }
                    }
                  } else {
                    await workoutNotifier
                        .updateWorkoutSet(workoutNotifier.newWorkout);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: workoutProviderState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      appendToExistingWorkoutSet!
                          ? "Update Your Workout Set"
                          : "Finish Your Workout Set",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

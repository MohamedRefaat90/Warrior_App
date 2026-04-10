import 'dart:ui';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shows a dialog to create a new workout set.
void showCreateWorkoutDialog(
  BuildContext context, {
  required TextEditingController nameController,
  required TextEditingController descriptionController,
  required GlobalKey<FormState> formKey,
  required WidgetRef ref,
}) {
  final workoutNotifier = ref.watch(workoutsProvider.notifier);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  nameController.clear();
  descriptionController.clear();

  // Haptic feedback
  HapticFeedback.mediumImpact();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'createWorkout'.tr(context),
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return _CreateWorkoutDialogContent(
        animation: animation,
        nameController: nameController,
        descriptionController: descriptionController,
        formKey: formKey,
        isDark: isDark,
        workoutNotifier: workoutNotifier,
      );
    },
  );
}

class _CreateWorkoutDialogContent extends StatelessWidget {
  final Animation<double> animation;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey;
  final bool isDark;
  final WorkoutsNotifier workoutNotifier;
  const _CreateWorkoutDialogContent({
    required this.animation,
    required this.nameController,
    required this.descriptionController,
    required this.formKey,
    required this.isDark,
    required this.workoutNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * animation.value,
            sigmaY: 5 * animation.value,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DialogHeader(isDark: isDark),
                  const SizedBox(height: 20),
                  Flexible(
                    child: _DialogForm(
                      formKey: formKey,
                      nameController: nameController,
                      descriptionController: descriptionController,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogActions(
                    formKey: formKey,
                    nameController: nameController,
                    descriptionController: descriptionController,
                    workoutNotifier: workoutNotifier,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogActions extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final WorkoutsNotifier workoutNotifier;
  const _DialogActions({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.workoutNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          child: Text(
            'cancel'.tr(context),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _handleCreate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            'create'.tr(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleCreate(BuildContext context) {
    if (formKey.currentState!.validate()) {
      workoutNotifier.newWorkout = WorkoutSetModel(
        name: nameController.text,
        description: descriptionController.text,
        workoutItems: [],
        createdAt: DateTime.now(),
      );
      // Reset provider state to idle so isSuccess from a prior creation
      // does not suppress the warning on this new workout.
      workoutNotifier.resetStateToIdle();
      context.pop();
      context.pushNamed(AppRouters.muscles, extra: {
        "isComingFromWorkoutScreen": true,
        "appendToExistingWorkoutSet": false,
      });
      HapticFeedback.lightImpact();
    }
  }
}

class _DialogForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isDark;
  const _DialogForm({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'workoutName'.tr(context),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              placeholderText: context.l10n.workoutNameExample,
              isObscure: false,
              textEditingController: nameController,
              validator: (value) =>
                  value!.isEmpty ? context.l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.descriptionOptional,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              textEditingController: descriptionController,
              isTextArea: true,
              isObscure: false,
              placeholderText: context.l10n.addWorkoutDetails,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final bool isDark;

  const _DialogHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'newWorkoutSet'.tr(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

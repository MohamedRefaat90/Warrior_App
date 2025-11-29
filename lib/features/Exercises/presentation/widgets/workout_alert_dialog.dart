import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkoutDialog extends StatefulWidget {
  const WorkoutDialog({super.key});

  @override
  _WorkoutDialogState createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<WorkoutDialog> {
  bool workoutAlert = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.createWorkoutSetWarning,
          ),
          CheckboxListTile.adaptive(
            value: workoutAlert,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              context.l10n.dontShowAgain,
              style: TextStyle(fontSize: 12),
            ),
            onChanged: (value) async {
              setState(() {
                workoutAlert = value!;
              });
              TalkerService.info(
                  'Workout alert preference updated', 'WORKOUT_DIALOG');
              SharedPref.setBool(StorageKeys.workoutAlert, workoutAlert);
            },
          ),
        ],
      ),
      actions: [
        CustomBTN(
            widget: Text(context.l10n.close),
            color: AppColors.black,
            padding: 12,
            width: double.infinity,
            press: () => context.pop())
      ],
    );
  }
}

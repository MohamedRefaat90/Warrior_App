import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/secure_storage_key.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              "To create your workout set you must select at least one exercise"
                  .capitalizeWord()),
          CheckboxListTile.adaptive(
            value: workoutAlert,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Don't show this again".capitalizeWord(),
              style: TextStyle(fontSize: 12),
            ),
            onChanged: (value) async {
              setState(() {
                workoutAlert = value!;
              });
              debugPrint(workoutAlert.toString());
              SharedPref.setBool(StorageKeys.workoutAlert, workoutAlert);
            },
          ),
        ],
      ),
      actions: [
        CustomBTN(
            widget: Text("Close"),
            color: AppColors.black,
            padding: 12,
            width: double.infinity,
            press: () => context.pop())
      ],
    );
  }
}

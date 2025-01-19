import 'package:Warrior/core/constants/secure_storage_key.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/refresh_widget.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscles_listview.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/workout_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MusclesScreen extends ConsumerStatefulWidget {
  final bool isComingFromWorkoutScreen;
  const MusclesScreen({super.key, this.isComingFromWorkoutScreen = false});
  @override
  ConsumerState<MusclesScreen> createState() => _MusclesScreenState();
}

class _MusclesScreenState extends ConsumerState<MusclesScreen> {
  bool workoutAlert = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Muscles',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Kings",
                  fontSize: 30)),
          centerTitle: true,
        ),
        body: ConnectivityChecker.isOnline!
            ? ref.watch(musclesProvider).when(
                loading: () => Center(child: const Loader()),
                data: (muscles) {
                  HiveManager.saveToHive(HiveManager.musclesBox, muscles);
                  return MusclesListView(
                      muscles: muscles,
                      isComingFromWorkoutScreen:
                          widget.isComingFromWorkoutScreen);
                },
                error: (error, stackTrace) => RefreshWidget(musclesProvider))
            : ValueListenableBuilder(
                valueListenable: HiveManager.musclesBox.listenable(),
                builder: (context, Box<MuscleModel> box, _) {
                  if (box.values.isEmpty) {
                    return Center(
                        child: Text('No muscles found.'.capitalizeWord()));
                  }

                  final muscles = box.values.toList();
                  return MusclesListView(
                      muscles: muscles,
                      isComingFromWorkoutScreen:
                          widget.isComingFromWorkoutScreen);
                },
              ));
  }

  @override
  void didChangeDependencies() {
    debugPrint('*************************************************');
    debugPrint("Exercise Objects => ${HiveManager.exercisesBox.length}");
    debugPrint("Muscles Objects => ${HiveManager.musclesBox.length}");
    debugPrint('*************************************************');
    super.didChangeDependencies();
    if (widget.isComingFromWorkoutScreen &&
        (SharedPref.getBool(StorageKeys.workoutAlert) == null ||
            SharedPref.getBool(StorageKeys.workoutAlert) == false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.isComingFromWorkoutScreen) {
          showDialog(
            context: context,
            builder: (context) => WorkoutDialog(),
          );
        }
      });
    }
  }
}

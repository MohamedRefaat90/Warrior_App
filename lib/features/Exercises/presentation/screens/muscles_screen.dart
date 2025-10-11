import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscles_listview.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/workout_alert_dialog.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/routers.dart';

class MusclesScreen extends ConsumerStatefulWidget {
  final bool isComingFromWorkoutScreen;
  final bool appendToExistingWorkoutSet;
  const MusclesScreen(
      {super.key,
      required this.isComingFromWorkoutScreen,
      required this.appendToExistingWorkoutSet});

  @override
  ConsumerState<MusclesScreen> createState() => _MusclesScreenState();
}

class _MusclesScreenState extends ConsumerState<MusclesScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Reset select mode when navigating back using device back button
        if (didPop && widget.isComingFromWorkoutScreen == true) {
          ref.read(workoutsProvider.notifier).selectMode = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Muscles',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Kings",
                  fontSize: 30)),
          centerTitle: true,
        ),
        floatingActionButton:
            SharedPref.getBool(StorageKeys.isGuestMode) == true
                ? FloatingActionButton(
                    heroTag: 'logout',
                    onPressed: () async {
                      await SecureStorageHandler.delete(key: StorageKeys.token);
                      TalkerService.info(
                          'User logged out from muscles screen', 'MUSCLES');
                      context.pushReplacementNamed(AppRouters.login);
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.logout, color: AppColors.white),
                  )
                : null,
        body: ConnectivityChecker.isOnline!
            ? ref.watch(musclesProvider).when(
                loading: () => Center(child: const Loader()),
                data: (muscles) {
                  HiveManager.saveToHive(HiveManager.musclesBox, muscles);
                  return MusclesListView(
                    muscles: muscles,
                    isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
                    appendToExistingWorkoutSet:
                        widget.appendToExistingWorkoutSet,
                  );
                },
                error: (error, stackTrace) =>
                    ref.read(musclesProvider).isRefreshing
                        ? Center(child: const Loader())
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Something went wrong!'),
                                ElevatedButton(
                                  onPressed: () => ref.refresh(musclesProvider),
                                  child: Text('Refresh'),
                                ),
                              ],
                            ),
                          ))
            : ValueListenableBuilder(
                valueListenable: HiveManager.musclesBox.listenable(),
                builder: (context, Box<MuscleModel> box, _) {
                  if (box.values.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No muscles available offline',
                            style: TextStyle(
                                fontFamily: "poppins",
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please go online to download muscle groups',
                            style: TextStyle(
                                fontFamily: "poppins",
                                fontSize: 16,
                                color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final muscles = box.values.toList();
                  return MusclesListView(
                    muscles: muscles,
                    isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
                    appendToExistingWorkoutSet:
                        widget.appendToExistingWorkoutSet,
                  );
                },
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      TalkerService.debug(
          'Current Route: ${router.state.matchedLocation}', 'MUSCLES');
      TalkerService.debug(
          'Is Online: ${ConnectivityChecker.isOnline}', 'MUSCLES');

      // Reset select mode when entering muscles screen from exercises
      // This ensures select mode doesn't persist when navigating back
      if (widget.isComingFromWorkoutScreen == true) {
        ref.read(workoutsProvider.notifier).selectMode = false;
      }

      if (router.state.matchedLocation == AppRouters.muscles &&
          (widget.isComingFromWorkoutScreen == true) &&
          (SharedPref.getBool(StorageKeys.workoutAlert) == null ||
              SharedPref.getBool(StorageKeys.workoutAlert) == false)) {
        TalkerService.info('Showing workout dialog...', 'MUSCLES');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WorkoutDialog(),
        );
      }
    });
  }
}

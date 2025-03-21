import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/routers.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutsProvider);
    final workoutNotifier = ref.watch(workoutsProvider.notifier);
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
        floatingActionButton: workoutNotifier.createWorkoutBtnState()
            ? CustomBTN(
                widget: Text("Create New Workout Set"),
                color: AppColors.primaryColor,
                padding: 12,
                radius: 8,
                press: () {
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Create Your Workout Set'),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextField(
                                    placeholderText: 'Workout Name Set',
                                    textEditingController: nameController,
                                    validator: (value) => value!.isEmpty
                                        ? 'workout set name is required'
                                            .capitalizeWord()
                                        : null),
                                SizedBox(height: 10.h),
                                CustomTextField(
                                    textEditingController:
                                        descriptionController,
                                    isTextArea: true,
                                    placeholderText: 'Description'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel')),
                            Consumer(
                              builder: (context, ref, child) => TextButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      workoutNotifier.fillNewWorkout(
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          workoutItems: []);
                                      context.pushNamed(AppRouters.muscles,
                                          extra: {
                                            "isComingFromWorkoutScreen": true,
                                            "appendToExistingWorkoutSet": false
                                          });
                                    }
                                  },
                                  child: Text('Create')),
                            ),
                          ],
                        );
                      });
                })
            : null,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Your Workouts',
              style: TextStyle(
                  fontFamily: 'kings',
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp)),
        ),
        body: ConnectivityChecker.isOnline!
            ? workoutState.isLoading
                ? const Loader()
                : workoutNotifier.workoutList.isEmpty
                    ? const EmptyWorkoutList()
                    : WorkoutsListview(workoutNotifier.workoutList,
                        nameController, descriptionController)
            : ValueListenableBuilder(
                valueListenable: HiveManager.workoutsBox.listenable(),
                builder: (context, Box<WorkoutSetModel> box, _) {
                  if (box.values.isEmpty) return const EmptyWorkoutList();

                  final workouts = box.toMap().entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key));

                  return WorkoutsListview(
                    workouts.map((e) => e.value).toList(),
                    nameController,
                    descriptionController,
                  );
                }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (ConnectivityChecker.isOnline!) {
        ref.read(workoutsProvider.notifier).getWorkoutSets();
      }
    });
  }
}

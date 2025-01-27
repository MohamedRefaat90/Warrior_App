import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Scaffold(
      floatingActionButton: CustomBTN(
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
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                              placeholderText: 'Workout Name Set',
                              textEditingController: _nameController,
                              validator: (value) => value!.isEmpty
                                  ? 'workout set name is required'
                                      .capitalizeWord()
                                  : null),
                          SizedBox(height: 10.h),
                          CustomTextField(
                              textEditingController: _descriptionController,
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
                              if (_formKey.currentState!.validate()) {
                                workoutNotifier.updateNewWorkout(
                                    name: _nameController.text,
                                    description: _descriptionController.text,
                                    user: ref
                                        .read(loginProvider.notifier)
                                        .user!
                                        .id);
                                context.pushNamed(AppRouters.muscles,
                                    extra: true);
                              }
                            },
                            child: Text('Create')),
                      ),
                    ],
                  );
                });
          }),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Your Workouts',
            style: TextStyle(
                fontFamily: 'kings',
                fontWeight: FontWeight.bold,
                fontSize: 28.sp)),
      ),
      body: workoutState.isLoading
          ? const Loader()
          : workoutNotifier.workoutList.isEmpty
              ? const EmptyWorkoutList()
              : WorkoutsListview(workoutNotifier.workoutList),
    );
  }
}

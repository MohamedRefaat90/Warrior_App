import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EmptyWorkoutList extends ConsumerStatefulWidget {
  const EmptyWorkoutList({super.key});

  @override
  ConsumerState<EmptyWorkoutList> createState() => _EmptyWorkoutListState();
}

class _EmptyWorkoutListState extends ConsumerState<EmptyWorkoutList> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('No Workouts Found',
            style: TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.bold,
                fontSize: 22.sp)),
        SizedBox(height: 20.h),
        CustomBTN(
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
                                textEditingController: descriptionController,
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
                                      description: descriptionController.text,
                                      workoutItems: []);
                                  Navigator.of(context).pop();
                                  context.pushNamed(AppRouters.muscles,
                                      extra: true);
                                }
                              },
                              child: Text('Create')),
                        ),
                      ],
                    );
                  });
            })
      ]),
    );
  }
}

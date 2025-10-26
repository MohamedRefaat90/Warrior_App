import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/services/interstitial_ad_manager.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routers.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final bool? showSuccessMessage;
  final String? workoutName;

  const WorkoutScreen({
    super.key,
    required this.showSuccessMessage,
    this.workoutName,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  // Controllers must be declared as instance variables and disposed
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    // Initialize controllers once
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    // Show success flushbar after the widget is built (only once per navigation)
    if (widget.showSuccessMessage == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showSuccessFlushbar(
            context,
            position: FlushbarPosition.BOTTOM,
            widget.workoutName != null
                ? 'Workout (${widget.workoutName}) added successfully!'
                    .capitalizeWord()
                : 'Workout added successfully!'.capitalizeWord(),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutsProvider);
    final workoutNotifier = ref.watch(workoutsProvider.notifier);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: workoutNotifier.createWorkoutBtnState()
            ? CustomBTN(
                widget: Text("New Workout Set"),
                color: AppColors.primaryColor,
                padding: 12,
                radius: 8,
                press: () {
                  // Clear previous text before showing dialog
                  _nameController.clear();
                  _descriptionController.clear();
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Create Workout Set'),
                          content: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextField(
                                    placeholderText: 'Workout Name Set',
                                    isObscure: false,
                                    textEditingController: _nameController,
                                    validator: (value) => value!.isEmpty
                                        ? 'workout set name is required'
                                            .capitalizeWord()
                                        : null),
                                SizedBox(height: 10.h),
                                CustomTextField(
                                    textEditingController:
                                        _descriptionController,
                                    isTextArea: true,
                                    isObscure: false,
                                    placeholderText: 'Description'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            Consumer(
                              builder: (context, ref, child) => TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Close the dialog first
                                      Navigator.of(context).pop();

                                      // Show interstitial ad, then navigate
                                      InterstitialAdManager.instance.showAd(
                                        onAdDismissed: () {
                                          // Navigate after ad is dismissed
                                          workoutNotifier.fillNewWorkout(
                                              name: _nameController.text,
                                              description:
                                                  _descriptionController.text,
                                              workoutItems: []);
                                          context.pushNamed(AppRouters.muscles,
                                              extra: {
                                                "isComingFromWorkoutScreen":
                                                    true,
                                                "appendToExistingWorkoutSet":
                                                    false
                                              });
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('Create')),
                            ),
                          ],
                        );
                      });
                })
            : null,
        appBar: AppBar(
          centerTitle: true,
          leading:
              BackButton(onPressed: () => context.goNamed(AppRouters.home)),
          title: Text('Your Workouts',
              style: TextStyle(
                  fontFamily: 'kings',
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp)),
        ),
        body: Column(
          children: [
            const BannerAdWidget(),
            Expanded(
              child: workoutState.isLoading
                  ? const Loader()
                  : workoutNotifier.workoutList.isEmpty
                      ? const EmptyWorkoutList()
                      : WorkoutsListview(
                          workoutNotifier.workoutList,
                          _nameController,
                          _descriptionController,
                        ),
            ),
          ],
        ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      ref.read(workoutsProvider.notifier).getWorkoutSets();
    });
  }
}

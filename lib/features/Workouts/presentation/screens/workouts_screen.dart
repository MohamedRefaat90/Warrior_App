import 'dart:ui';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/services/interstitial_ad_manager.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final GlobalKey<FormState> _formKey;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScaleAnimation;
  late final Animation<double> _fabRotationAnimation;

  @override
  Widget build(BuildContext context) {
    final workoutNotifier = ref.watch(workoutsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: false,
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      floatingActionButton: workoutNotifier.createWorkoutBtnState()
          ? ScaleTransition(
              scale: _fabScaleAnimation,
              child: RotationTransition(
                turns: _fabRotationAnimation,
                child: FloatingActionButton.extended(
                  elevation: 8,
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded, size: 28),
                  label: Text(
                    'New Workout',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () => _showCreateWorkoutDialog(context),
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark),
          const SliverToBoxAdapter(child: BannerAdWidget()),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          _buildWorkoutContent(),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      ref.read(workoutsProvider.notifier).getWorkoutSets();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    // Initialize FAB animations
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animate FAB entrance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.primaryColor,
        ),
        onPressed: () => context.goNamed(AppRouters.home),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Material(
          color: Colors.transparent,
          child: Text(
            'Your Workouts',
            style: TextStyle(
              fontFamily: 'kings',
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              color: isDark ? Colors.white : Colors.black87,
              shadows: [
                Shadow(
                  color: AppColors.primaryColor!.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.black,
                      Colors.black.withOpacity(0.8),
                    ]
                  : [
                      Colors.grey[50]!,
                      Colors.grey[50]!.withOpacity(0.8),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutContent() {
    final workoutState = ref.watch(workoutsProvider);
    final workoutNotifier = ref.watch(workoutsProvider.notifier);

    if (workoutState.isLoading) {
      return const SliverFillRemaining(
        child: Loader(),
      );
    }

    if (workoutNotifier.workoutList.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyWorkoutList(),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: WorkoutsListview(
                  workoutNotifier.workoutList,
                  _nameController,
                  _descriptionController,
                ),
              ),
            );
          },
          childCount: 1,
        ),
      ),
    );
  }

  void _showCreateWorkoutDialog(BuildContext context) {
    final workoutNotifier = ref.watch(workoutsProvider.notifier);

    _nameController.clear();
    _descriptionController.clear();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Create Workout',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: 10,
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Create Workout Set',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workout Name',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          placeholderText: 'e.g., Full Body Blast',
                          isObscure: false,
                          textEditingController: _nameController,
                          validator: (value) => value!.isEmpty
                              ? 'Workout set name is required'.capitalizeWord()
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Description (Optional)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          textEditingController: _descriptionController,
                          isTextArea: true,
                          isObscure: false,
                          placeholderText: 'Add workout details...',
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) => ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          HapticFeedback.lightImpact();

                          InterstitialAdManager.instance.showAd(
                            onAdDismissed: () {
                              workoutNotifier.fillNewWorkout(
                                name: _nameController.text,
                                description: _descriptionController.text,
                                workoutItems: [],
                              );
                              context.pushNamed(
                                AppRouters.muscles,
                                extra: {
                                  "isComingFromWorkoutScreen": true,
                                  "appendToExistingWorkoutSet": false,
                                },
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

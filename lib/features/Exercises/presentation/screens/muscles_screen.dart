import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/providers/cache_provider.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/offline_view.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/data/repo/exercises_repo.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/download_progress_indicator.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/error_card.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscles_gridview.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscles_listview.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/workout_alert_dialog.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MusclesContent extends StatelessWidget {
  final List<MuscleModel> muscles;
  final bool isGridView;
  final bool isComingFromWorkoutScreen;
  final bool appendToExistingWorkoutSet;
  const MusclesContent(
      {super.key,
      required this.muscles,
      required this.isGridView,
      required this.isComingFromWorkoutScreen,
      required this.appendToExistingWorkoutSet});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(isGridView),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: isGridView
            ? MusclesGridView(
                muscles: muscles,
                isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                appendToExistingWorkoutSet: appendToExistingWorkoutSet,
              )
            : MusclesListView(
                muscles: muscles,
                isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                appendToExistingWorkoutSet: appendToExistingWorkoutSet,
              ),
      ),
    );
  }
}

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

/// Grid view for muscles with fancy card design

class _MusclesScreenState extends ConsumerState<MusclesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isGridView = SharedPref.getBool(StorageKeys.isGridView) ?? false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && widget.isComingFromWorkoutScreen == true) {
          ref.read(workoutsProvider.notifier).selectMode = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Muscles',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Kings",
              fontSize: 32,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  _isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  key: ValueKey(_isGridView),
                  color: AppColors.primaryColor,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                  SharedPref.setBool(StorageKeys.isGridView, _isGridView);
                });
              },
              tooltip: _isGridView ? 'List View' : 'Grid View',
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  ConnectivityChecker.isOnline!
                      ? const BannerAdWidget()
                      : const SizedBox.shrink(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ConnectivityChecker.isOnline!
                            ? ref.watch(musclesProvider).when(
                                  loading: () => Loader(),
                                  data: (muscles) {
                                    HiveManager.saveToHive(
                                        HiveManager.musclesBox, muscles);

                                    // Start caching all exercises in the background
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _startCachingAllExercises(ref, muscles);
                                    });

                                    return MusclesContent(
                                        muscles: muscles,
                                        isGridView: _isGridView,
                                        isComingFromWorkoutScreen:
                                            widget.isComingFromWorkoutScreen,
                                        appendToExistingWorkoutSet:
                                            widget.appendToExistingWorkoutSet);
                                  },
                                  error: (error, stackTrace) =>
                                      ref.read(musclesProvider).isRefreshing
                                          ? Loader()
                                          : ErrorCard(),
                                )
                            : ValueListenableBuilder(
                                valueListenable:
                                    HiveManager.musclesBox.listenable(),
                                builder: (context, Box<MuscleModel> box, _) {
                                  if (box.values.isEmpty) {
                                    return OfflineView(
                                      title: 'No muscles available offline',
                                      subtitle:
                                          'Please go online to download muscle groups',
                                    );
                                  }

                                  final muscles = box.values.toList();
                                  return MusclesContent(
                                      muscles: muscles,
                                      isGridView: _isGridView,
                                      isComingFromWorkoutScreen:
                                          widget.isComingFromWorkoutScreen,
                                      appendToExistingWorkoutSet:
                                          widget.appendToExistingWorkoutSet);
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              // Global progress indicator
              const DownloadProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      TalkerService.debug(
          'Current Route: ${router.state.matchedLocation}', 'MUSCLES');
      TalkerService.debug(
          'Is Online: ${ConnectivityChecker.isOnline}', 'MUSCLES');

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

  /// Start caching all exercises for all muscles in the background
  Future<void> _startCachingAllExercises(
    WidgetRef ref,
    List<MuscleModel> muscles,
  ) async {
    try {
      final muscleIds = muscles.map((m) => m.id).toList();
      final allExercises =
          await ref.read(exercisesRepo).getAllExercises(muscleIds: muscleIds);

      if (allExercises.isNotEmpty) {
        ref
            .read(cacheProgressProvider.notifier)
            .startCaching(exercises: allExercises);
      }
    } catch (e) {
      TalkerService.error('Failed to start caching all exercises', 'CACHE', e);
    }
  }
}

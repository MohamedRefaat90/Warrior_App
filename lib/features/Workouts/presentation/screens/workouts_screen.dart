import 'package:Warrior/core/services/interstitial_ad_manager.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/create_workout_dialog.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workout_app_bar.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workout_fab.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // Watch state so the widget rebuilds when workoutList changes
    // (e.g. FAB visibility after creating/deleting the first workout).
    ref.watch(workoutsProvider);
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: false,
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      floatingActionButton: workoutNotifier.createWorkoutBtnState()
          ? WorkoutFab(
              scaleAnimation: _fabScaleAnimation,
              rotationAnimation: _fabRotationAnimation,
              onPressed: () {
                InterstitialAdManager.instance.showAd(
                  onAdDismissed: () {
                    showCreateWorkoutDialog(
                      context,
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      formKey: _formKey,
                      ref: ref,
                    );
                  },
                );
              },
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const WorkoutAppBar(),
          const SliverToBoxAdapter(
              child: BannerAdWidget(
                  adUnitId: "ca-app-pub-7417773148722475/7890579794")),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          WorkoutListContent(
            nameController: _nameController,
            descriptionController: _descriptionController,
          ),
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
      final workoutAd = InterstitialAdManager.forAdUnit(
          "ca-app-pub-7417773148722475/3568191408");
      workoutAd.loadAd();
      TalkerService.debug('Workout ad loaded', 'WORKOUT_AD');
    });
  }
}

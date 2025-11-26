import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/offline_view.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/provider/predefined_provider.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_groups_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredefinedWorkoutsScreen extends ConsumerStatefulWidget {
  const PredefinedWorkoutsScreen({super.key});

  @override
  ConsumerState<PredefinedWorkoutsScreen> createState() =>
      _PredefinedWorkoutScreenState();
}

class _PredefinedWorkoutScreenState
    extends ConsumerState<PredefinedWorkoutsScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the grouped workouts provider instead of flat list
    final groupedWorkoutsState = ref.watch(groupedWorkoutsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Predefined Workouts',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'kings',
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: groupedWorkoutsState.when(
        data: (workoutGroups) {
          // Check if the list is empty
          if (workoutGroups.isEmpty) {
            return OfflineView(
              title: 'No predefined workouts available offline',
              subtitle: 'Please go online to download it',
            );
          }
          // Use the new grouped view with domain entities
          return WorkoutGroupsView(workoutGroups: workoutGroups);
        },
        loading: () => const Loader(),
        error: (error, stackTrace) {
          final isOffline = ConnectivityChecker.isOnline == false;
          return Center(
            child: Padding(
              padding: context.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline ? Icons.wifi_off : Icons.error_outline,
                    size: ResponsiveUtils.value<double>(
                      context,
                      mobile: 48,
                      tablet: 56,
                      desktop: 64,
                    ),
                    color: isOffline ? Colors.orange : Colors.red,
                  ),
                  SizedBox(height: context.mediumSpacing),
                  Text(
                    isOffline ? 'You are offline' : 'Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: context.smallSpacing),
                  Text(
                    isOffline
                        ? 'No cached workouts available. Connect to the internet to download workouts.'
                        : 'Failed to load predefined workouts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  SizedBox(height: context.mediumSpacing),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the grouped workouts provider
                      ref.invalidate(groupedWorkoutsProvider);
                    },
                    child: Text('retry'.tr(context)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    Future.microtask(() {
      ref.invalidate(groupedWorkoutsProvider, asReload: true);
    });
    super.initState();
  }
}

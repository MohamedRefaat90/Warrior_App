import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/offline_error.dart';
import 'package:Warrior/core/widgets/offline_view.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/provider/predefined_provider.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_groups_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredefinedWorkoutsScreen extends ConsumerWidget {
  const PredefinedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedWorkoutsState = ref.watch(groupedWorkoutsProvider);
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.l10n.popularWorkouts,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: appSettings.fontFamily(),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: groupedWorkoutsState.when(
        data: (workoutGroups) {
          if (workoutGroups.isEmpty) {
            return OfflineView(
              title: context.l10n.noPredefinedWorkoutsOffline,
              subtitle: context.l10n.pleaseGoOnlineToDownload,
            );
          }
          return WorkoutGroupsView(workoutGroups: workoutGroups);
        },
        loading: () => const Loader(),
        error: (error, stackTrace) {
          final isOffline = ConnectivityChecker.isOnline == false;
          return ref.read(groupedWorkoutsProvider).isRefreshing
              ? Loader()
              : OfflineError(
                  isOffline: isOffline, provider: groupedWorkoutsProvider);
        },
      ),
    );
  }
}

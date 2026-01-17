import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/app_open_ad_manager.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:Warrior/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:oktoast/oktoast.dart';

/// Test-friendly entry point for the Warrior app
/// This skips Firebase and platform-specific initialization
Future<void> testMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app services in test mode (skips Firebase/FCM/SharedPrefs/Hive)
  await AppServices.init(isTestMode: true);

  // Create test Dio instance for use in tests
  final testDio = DioHandler.createTestDio();
  final testAuthRepo = AuthRepo(testDio);
  final testWorkoutRepo = WorkoutRepo(testDio);

  runApp(
    ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(testDio),
        authRepo.overrideWithValue(testAuthRepo),
        workoutRepo.overrideWithValue(testWorkoutRepo),
        // Override sync service to prevent timer-based sync in tests
        syncServiceProvider.overrideWith(TestSyncService.new),
      ],
      child: const WarriorTestApp(),
    ),
  );
}

// Test-friendly SyncService that doesn't create timers
class TestSyncService extends SyncService {
  @override
  SyncState build() {
    // Initialize repository but don't start sync
    workoutRepository = ref.read(workoutRepo);
    foodSearchRepository = ref.read(productWriteRepositoryProvider);
    // Don't call _initSync() to avoid creating timers in tests
    return const SyncState();
  }

  @override
  Future<void> syncPendingOperations() async {
    // Mock implementation - no actual syncing in tests
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 10));
    state = state.copyWith(isLoading: false);
  }
}

/// Test version of WarriorApp that doesn't include Sentry or DevicePreview
class WarriorTestApp extends ConsumerStatefulWidget {
  const WarriorTestApp({super.key});

  @override
  ConsumerState<WarriorTestApp> createState() => _WarriorTestAppState();
}

/// Sync status indicator widget
class _SyncIndicator extends ConsumerWidget {
  const _SyncIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);
    if (!syncState.isLoading) return const SizedBox.shrink();

    return Container(
      width: 80,
      height: 25,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 70),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black87,
      ),
      child: Lottie.asset(
        AppAssets.loader,
        errorBuilder: (context, error, stackTrace) {
          TalkerService.warning(
            'Failed to load sync animation',
            'LOTTIE',
            error,
          );
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
      ),
    );
  }
}

class _WarriorTestAppState extends ConsumerState<WarriorTestApp>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // Initialize connectivity checker
    ConnectivityChecker.initialize(ref);

    return OKToast(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MaterialApp.router(
            title: 'Warrior',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 168, 11, 11),
              ),
              useMaterial3: true,
            ),
            routerConfig: RoutersManager.router,
          ),
          // Sync indicator overlay
          const _SyncIndicator(),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Show app open ad when app resumes (skip in tests)
    if (state == AppLifecycleState.resumed) {
      // AppOpenAdManager would be null or no-op in test mode
      try {
        AppOpenAdManager.instance.showAdIfAvailable();
      } catch (_) {
        // Ignore ad errors in tests
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
}

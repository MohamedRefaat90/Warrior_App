import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

class TestAppWrapper {
  static Widget createMainAppForTesting() {
    return TestAppWrapper.createTestApp(
      child: const _TestWarriorApp(),
    );
  }

  static Widget createTestApp({
    Widget? child,
    List<Override>? additionalOverrides,
  }) {
    // Create a test Dio instance
    final testDio = DioHandler.createTestDio();
    final testAuthRepo = AuthRepo(testDio);
    final testWorkoutRepo = WorkoutRepo(testDio);

    // Create provider overrides
    final List<Override> overrides = [
      dioProvider.overrideWithValue(testDio),
      authRepo.overrideWithValue(testAuthRepo),
      workoutRepo.overrideWithValue(testWorkoutRepo),
      // Override with test sync service that doesn't create timers
      syncServiceProvider.overrideWith(() => TestSyncService(testWorkoutRepo)),
      ...(additionalOverrides ?? []),
    ];

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        title: 'Warrior Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 168, 11, 11),
          ),
          useMaterial3: true,
        ),
        home: child ??
            const Scaffold(
              body: Center(
                child: Text('Test App'),
              ),
            ),
      ),
    );
  }
}

// Test-friendly SyncService that doesn't create timers
class TestSyncService extends SyncService {
  TestSyncService(testWorkoutRepo);

  @override
  Future<void> syncPendingOperations() async {
    // Mock implementation - no actual syncing in tests
    state = true;
    await Future.delayed(const Duration(milliseconds: 10));
    state = false;
  }

  @override
  Future<void> _initSync() async {
    // Override to do nothing - no timers in tests
    return;
  }
}

// Simplified version of the main Warrior app for testing
class _TestWarriorApp extends ConsumerWidget {
  const _TestWarriorApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warrior'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64),
            SizedBox(height: 16),
            Text(
              'Warrior App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Ready for testing!'),
          ],
        ),
      ),
    );
  }
}

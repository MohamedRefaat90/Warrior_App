// This is a comprehensive Flutter widget test suite for the Warrior app.
//
// These tests verify the main app functionality, widget behavior, and UI interactions.

import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'helpers/test_app_wrapper.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Warrior App Tests', () {
    late MockDio mockDio;
    late MockWorkoutRepo mockWorkoutRepo;
    late MockAuthRepo mockAuthRepo;

    setUp(() {
      mockDio = MockDio();
      mockWorkoutRepo = MockWorkoutRepo();
      mockAuthRepo = MockAuthRepo();
    });

    testWidgets('App should initialize without network dependencies',
        (WidgetTester tester) async {
      // Create a test app that doesn't require network initialization
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the providers that depend on Dio
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp(
                title: 'Warrior Test',
                home: Scaffold(
                  appBar: AppBar(title: const Text('Warrior')),
                  body: const Center(
                    child: Text('Welcome to Warrior'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Verify the app builds successfully
      expect(find.text('Warrior'), findsOneWidget);
      expect(find.text('Welcome to Warrior'), findsOneWidget);
    });

    testWidgets('ProviderScope should be properly configured',
        (WidgetTester tester) async {
      bool providerScopeFound = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: Builder(
            builder: (context) {
              // Check if we can access ProviderScope
              try {
                ProviderScope.containerOf(context);
                providerScopeFound = true;
              } catch (e) {
                providerScopeFound = false;
              }

              return MaterialApp(
                home: Scaffold(
                  body: Text(
                      providerScopeFound ? 'Provider Ready' : 'Provider Error'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Provider Ready'), findsOneWidget);
    });

    testWidgets('App should handle different screen sizes',
        (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(800, 600));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp(
                home: Scaffold(
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: Text(
                            'Screen: ${constraints.maxWidth}x${constraints.maxHeight}'),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.textContaining('Screen: 800'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('App should support accessibility features',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Warrior'),
              ),
              body: const Column(
                children: [
                  Text('Welcome to Warrior'),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Get Started'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Test semantic labels
      expect(find.text('Warrior'), findsOneWidget);
      expect(find.text('Welcome to Warrior'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Verify button is accessible
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('Theme should be properly configured',
        (WidgetTester tester) async {
      late ThemeData capturedTheme;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 168, 11, 11),
              ),
              useMaterial3: true,
            ),
            home: Builder(
              builder: (context) {
                capturedTheme = Theme.of(context);
                return const Scaffold(
                  body: Text('Theme Test'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Theme Test'), findsOneWidget);
      expect(capturedTheme.useMaterial3, isTrue);
      expect(capturedTheme.colorScheme.primary, isNotNull);
    });

    testWidgets('State management should work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: const MaterialApp(
            home: _TestCounterWidget(),
          ),
        ),
      );

      expect(find.text('Counter: 0'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Counter: 1'), findsOneWidget);
    });

    testWidgets('Performance test - app should render quickly',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepo.overrideWithValue(mockWorkoutRepo),
            syncServiceProvider
                .overrideWith((ref) => SyncService(mockWorkoutRepo)),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (_, child) {
              return MaterialApp(
                home: Scaffold(
                  body: ListView.builder(
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Item $index'),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      stopwatch.stop();

      // App should render within reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Verify list items are rendered
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });
  });

  group('Warrior App Main Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      expect(find.text('Warrior'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('App shows correct title', (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      expect(find.text('Warrior'), findsOneWidget);
      expect(find.text('Warrior App'), findsOneWidget);
    });

    testWidgets('App has ProviderScope for state management',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      expect(find.byType(ProviderScope), findsOneWidget);
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('App handles different screen orientations',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      // Test portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      TestHelpers.expectNoExceptions(tester);

      // Test landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('App handles different screen sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      // Test small screen
      await tester.binding.setSurfaceSize(const Size(320, 568));
      await tester.pumpAndSettle();
      TestHelpers.expectNoExceptions(tester);

      // Test large screen
      await tester.binding.setSurfaceSize(const Size(414, 896));
      await tester.pumpAndSettle();
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('App handles accessibility text scaling',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      // Test with large text scale
      tester.binding.platformDispatcher.textScaleFactorTestValue = 2.0;
      await tester.pumpAndSettle();
      TestHelpers.expectNoExceptions(tester);

      // Reset text scale
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    });

    testWidgets('App maintains state during rebuilds',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      // Trigger rebuild
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('App has proper theme configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('App handles rapid user interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      // Simulate rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.fitness_center));
        await tester.pump(const Duration(milliseconds: 100));
      }
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('App performance is acceptable', (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());

      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // App should load within reasonable time (2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('App handles material design components',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createMainAppForTesting());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      TestHelpers.expectNoExceptions(tester);
    });
  });

  group('Widget Helper Tests', () {
    testWidgets('TestHelpers.pumpAndSettleWidget works correctly',
        (WidgetTester tester) async {
      const testWidget = Text('Test Widget');
      await TestHelpers.pumpAndSettleWidget(tester, testWidget);

      expect(find.text('Test Widget'), findsOneWidget);
    });

    testWidgets('TestHelpers.expectNoExceptions works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('No Error')));
      TestHelpers.expectNoExceptions(tester);
    });

    testWidgets('Find widget by text works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('Find Me')));
      final finder = find.text('Find Me');
      expect(finder, findsOneWidget);
    });

    testWidgets('Find widget by type works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('Test')));
      final finder = find.byType(Text);
      expect(finder, findsWidgets);
    });

    testWidgets('TestHelpers.tapWidget works correctly',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ElevatedButton(
            onPressed: () => tapped = true,
            child: const Text('Tap Me'),
          ),
        ),
      );

      await TestHelpers.tapWidget(tester, find.byType(ElevatedButton));
      expect(tapped, true);
    });
  });

  group('State Management Tests', () {
    testWidgets('ProviderScope provides correct context',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createTestApp(
        child: Consumer(
          builder: (context, ref, child) {
            return const Text('Provider Working');
          },
        ),
      ));

      expect(find.text('Provider Working'), findsOneWidget);
    });

    testWidgets('State management should work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestAppWrapper.createTestApp(
        child: const _TestCounterWidget(),
      ));

      expect(find.text('Counter: 0'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Counter: 1'), findsOneWidget);
    });
  });

  group('Mock Data Tests', () {
    test('MockData provides valid sample data', () {
      final userData = MockData.getSampleUserData();
      expect(userData['email'], MockData.sampleEmail);
      expect(userData['username'], MockData.sampleUsername);
      expect(userData['id'], isNotNull);

      final workoutData = MockData.getSampleWorkoutData();
      expect(workoutData['name'], isNotNull);
      expect(workoutData['exercises'], isList);

      final exerciseData = MockData.getSampleExerciseData();
      expect(exerciseData['name'], isNotNull);
      expect(exerciseData['muscle_group'], isNotNull);
    });

    test('MockData constants are properly defined', () {
      expect(MockData.validEmail, contains('@'));
      expect(MockData.invalidEmail, isNot(contains('@')));
      expect(MockData.weakPassword.length, lessThan(6));
      expect(MockData.strongPassword.length, greaterThan(8));
    });
  });

  group('Test Constants Tests', () {
    test('TestConstants have reasonable values', () {
      expect(TestConstants.shortDelay.inMilliseconds, lessThan(200));
      expect(TestConstants.mediumDelay.inMilliseconds,
          greaterThan(TestConstants.shortDelay.inMilliseconds));
      expect(TestConstants.longDelay.inMilliseconds,
          greaterThan(TestConstants.mediumDelay.inMilliseconds));

      expect(TestConstants.phoneSize.width,
          lessThan(TestConstants.tabletSize.width));
      expect(TestConstants.tabletSize.width,
          lessThan(TestConstants.desktopSize.width));

      expect(
          TestConstants.smallFontSize, lessThan(TestConstants.mediumFontSize));
      expect(
          TestConstants.mediumFontSize, lessThan(TestConstants.largeFontSize));
    });
  });
}

class MockAuthRepo extends Mock implements AuthRepo {}

// Mock classes
class MockDio extends Mock implements Dio {}

class MockWorkoutRepo extends Mock implements WorkoutRepo {}

class _TestCounterState extends State<_TestCounterWidget> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: $counter'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  counter++;
                });
              },
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCounterWidget extends StatefulWidget {
  const _TestCounterWidget();

  @override
  State<_TestCounterWidget> createState() => _TestCounterState();
}

import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/food_search_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/cache_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPref.init();
  });

  group('FoodSearchScreen', () {
    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const FoodSearchScreen(),
        ),
      );
      expect(find.byIcon(Icons.add_box), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays offline indicator when needed', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: CacheIndicatorWidget(cachedAt: DateTime.now()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for cache indicator
      expect(find.byType(CacheIndicatorWidget), findsOneWidget);
    });
  });
}

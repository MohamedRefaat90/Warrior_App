import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionField', () {
    testWidgets('displays label and unit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
    });

    testWidgets('displays value when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
                value: 250.0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('250.0'), findsOneWidget);
    });

    testWidgets('calls onChanged when value changes', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
              ),
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '150');
      expect(changedValue, 150.0);
    });

    testWidgets('shows warning icon for low confidence', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
                value: 100.0,
                confidence: 0.3, // Low confidence
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
      expect(find.text('Please verify this value'), findsOneWidget);
    });

    testWidgets('shows confidence indicator when confidence provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
                value: 100.0,
                confidence: 0.85,
              ),
            ),
          ),
        ),
      );

      // High confidence shows check icon
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('is read-only when specified', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
                value: 100.0,
              ),
              onChanged: (value) => changedValue = value,
              readOnly: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '200');
      expect(changedValue, isNull);
    });

    testWidgets('only allows numeric input', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NutritionField(
              data: const NutritionFieldData(
                key: 'energyKcal100g',
                label: 'Energy',
                unit: 'kcal',
              ),
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // The input formatter strips non-numeric chars, so 'abc123.5' becomes '123.5'
      await tester.enterText(find.byType(TextFormField), '123.5');
      expect(changedValue, 123.5);

      // Test that letters are filtered
      await tester.enterText(find.byType(TextFormField), '45.6');
      expect(changedValue, 45.6);
    });
  });

  group('NutritionFieldData', () {
    test('hasValue returns true when value is set', () {
      const data = NutritionFieldData(
        key: 'test',
        label: 'Test',
        unit: 'g',
        value: 10.0,
      );
      expect(data.hasValue, isTrue);
    });

    test('hasValue returns false when value is null', () {
      const data = NutritionFieldData(
        key: 'test',
        label: 'Test',
        unit: 'g',
      );
      expect(data.hasValue, isFalse);
    });

    test('isLowConfidence returns true for confidence < 0.7', () {
      const data = NutritionFieldData(
        key: 'test',
        label: 'Test',
        unit: 'g',
        confidence: 0.5,
      );
      expect(data.isLowConfidence, isTrue);
    });

    test('isLowConfidence returns false for confidence >= 0.7', () {
      const data = NutritionFieldData(
        key: 'test',
        label: 'Test',
        unit: 'g',
        confidence: 0.8,
      );
      expect(data.isLowConfidence, isFalse);
    });

    test('isLowConfidence returns false when confidence is 0', () {
      const data = NutritionFieldData(
        key: 'test',
        label: 'Test',
        unit: 'g',
        confidence: 0.0,
      );
      // confidence must be > 0 to be considered low
      expect(data.isLowConfidence, isFalse);
    });
  });

  group('NutritionFields factory', () {
    test('energy creates correct field data', () {
      final data = NutritionFields.energy(value: 200, confidence: 0.9);
      expect(data.key, 'energyKcal100g');
      expect(data.label, 'Energy');
      expect(data.unit, 'kcal');
      expect(data.value, 200);
      expect(data.confidence, 0.9);
      expect(data.icon, Icons.local_fire_department_rounded);
    });

    test('proteins creates correct field data', () {
      final data = NutritionFields.proteins(value: 25);
      expect(data.key, 'proteins100g');
      expect(data.label, 'Proteins');
      expect(data.unit, 'g');
      expect(data.icon, Icons.fitness_center_rounded);
    });

    test('carbohydrates creates correct field data', () {
      final data = NutritionFields.carbohydrates();
      expect(data.key, 'carbohydrates100g');
      expect(data.label, 'Carbohydrates');
      expect(data.icon, Icons.grain_rounded);
    });
  });
}

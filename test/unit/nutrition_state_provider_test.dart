import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/nutrition_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionState', () {
    test('initial state has correct defaults', () {
      const state = NutritionState();
      expect(state.facts, isNull);
      expect(state.isExpanded, isFalse);
      expect(state.dataMode, '100g');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('hasData returns false when facts is null', () {
      const state = NutritionState();
      expect(state.hasData, isFalse);
    });

    test('hasData returns true when facts has populated fields', () {
      const state = NutritionState(
        facts: NutritionFacts(energyKcal100g: 200),
      );
      expect(state.hasData, isTrue);
    });

    test('fieldCount returns 0 when facts is null', () {
      const state = NutritionState();
      expect(state.fieldCount, 0);
    });

    test('copyWith creates new state with updated values', () {
      const state = NutritionState();
      final newState = state.copyWith(isExpanded: true, dataMode: 'serving');

      expect(newState.isExpanded, isTrue);
      expect(newState.dataMode, 'serving');
      expect(newState.facts, isNull);
    });

    test('copyWith with clearError removes error', () {
      const state = NutritionState(error: 'Some error');
      final newState = state.copyWith(clearError: true);

      expect(newState.error, isNull);
    });

    test('copyWith with clearFacts removes facts', () {
      const state = NutritionState(
        facts: NutritionFacts(energyKcal100g: 100),
      );
      final newState = state.copyWith(clearFacts: true);

      expect(newState.facts, isNull);
    });
  });

  group('NutritionStateNotifier', () {
    late ProviderContainer container;
    late NutritionStateNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(nutritionStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('build returns initial state', () {
      final state = container.read(nutritionStateProvider);
      expect(state.isExpanded, isFalse);
      expect(state.dataMode, '100g');
    });

    test('toggleExpanded toggles isExpanded', () {
      notifier.toggleExpanded();
      expect(container.read(nutritionStateProvider).isExpanded, isTrue);

      notifier.toggleExpanded();
      expect(container.read(nutritionStateProvider).isExpanded, isFalse);
    });

    test('setExpanded sets isExpanded to specific value', () {
      notifier.setExpanded(true);
      expect(container.read(nutritionStateProvider).isExpanded, isTrue);

      notifier.setExpanded(false);
      expect(container.read(nutritionStateProvider).isExpanded, isFalse);
    });

    test('setDataMode updates dataMode', () {
      notifier.setDataMode('serving');
      expect(container.read(nutritionStateProvider).dataMode, 'serving');
    });

    test('setDataMode does nothing if same mode', () {
      notifier.setDataMode('100g');
      // Should not throw or cause issues
      expect(container.read(nutritionStateProvider).dataMode, '100g');
    });

    test('updateFacts updates facts and clears error', () {
      notifier.setError('Some error');
      notifier.updateFacts(const NutritionFacts(energyKcal100g: 250));

      final state = container.read(nutritionStateProvider);
      expect(state.facts?.energyKcal100g, 250);
      expect(state.error, isNull);
    });

    test('setLoading updates isLoading', () {
      notifier.setLoading(true);
      expect(container.read(nutritionStateProvider).isLoading, isTrue);

      notifier.setLoading(false);
      expect(container.read(nutritionStateProvider).isLoading, isFalse);
    });

    test('setError updates error', () {
      notifier.setError('Test error');
      expect(container.read(nutritionStateProvider).error, 'Test error');
    });

    test('setError with null clears error', () {
      notifier.setError('Test error');
      notifier.setError(null);
      expect(container.read(nutritionStateProvider).error, isNull);
    });

    test('clearError removes error', () {
      notifier.setError('Test error');
      notifier.clearError();
      expect(container.read(nutritionStateProvider).error, isNull);
    });

    test('reset returns to initial state', () {
      notifier.updateFacts(const NutritionFacts(energyKcal100g: 100));
      notifier.setExpanded(true);
      notifier.setDataMode('serving');
      notifier.setError('error');

      notifier.reset();

      final state = container.read(nutritionStateProvider);
      expect(state.facts, isNull);
      expect(state.isExpanded, isFalse);
      expect(state.dataMode, '100g');
      expect(state.error, isNull);
    });
  });
}

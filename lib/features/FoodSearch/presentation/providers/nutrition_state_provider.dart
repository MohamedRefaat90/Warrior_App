import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing nutrition facts UI state.
final nutritionStateProvider =
    NotifierProvider<NutritionStateNotifier, NutritionState>(
  NutritionStateNotifier.new,
);

/// Immutable state for nutrition facts UI.
class NutritionState {
  final NutritionFacts? facts;
  final bool isExpanded;
  final String dataMode;
  final bool isLoading;
  final String? error;

  const NutritionState({
    this.facts,
    this.isExpanded = false,
    this.dataMode = '100g',
    this.isLoading = false,
    this.error,
  });

  double get averageConfidence {
    if (facts == null) return 0.0;
    final fields = facts!.getPopulatedFields();
    if (fields.isEmpty) return 0.0;
    return fields.fold<double>(
          0.0,
          (sum, field) => sum + facts!.getFieldConfidence(field),
        ) /
        fields.length;
  }

  int get fieldCount => facts?.populatedFieldCount ?? 0;
  bool get hasData => facts != null && facts!.populatedFieldCount > 0;
  bool get hasLowConfidenceFields =>
      facts?.getLowConfidenceFields().isNotEmpty ?? false;

  NutritionState copyWith({
    NutritionFacts? facts,
    bool? isExpanded,
    String? dataMode,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearFacts = false,
  }) {
    return NutritionState(
      facts: clearFacts ? null : (facts ?? this.facts),
      isExpanded: isExpanded ?? this.isExpanded,
      dataMode: dataMode ?? this.dataMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for managing nutrition facts UI state.
class NutritionStateNotifier extends Notifier<NutritionState> {
  @override
  NutritionState build() => const NutritionState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const NutritionState();
  }

  void setDataMode(String mode) {
    if (mode == state.dataMode) return;

    NutritionFacts? convertedFacts = state.facts;
    if (state.facts != null) {
      convertedFacts = mode == '100g'
          ? state.facts!.convertToPer100g()
          : state.facts!.convertToPerServing();
    }

    state = state.copyWith(dataMode: mode, facts: convertedFacts);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, clearError: error == null);
  }

  void setExpanded(bool expanded) {
    state = state.copyWith(isExpanded: expanded);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void updateFacts(NutritionFacts facts) {
    state = state.copyWith(facts: facts, clearError: true);
  }
}

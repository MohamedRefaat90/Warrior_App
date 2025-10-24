import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/CaloriesCalculator/data/models/calories_result_model.dart';
import 'package:Warrior/features/CaloriesCalculator/data/models/user_data_model.dart';
import 'package:Warrior/features/CaloriesCalculator/data/repo/calories_calculator_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for calories calculator state management
final caloriesCalculatorProvider =
    NotifierProvider<CaloriesCalculatorNotifier, CaloriesCalculatorState>(
  CaloriesCalculatorNotifier.new,
);

/// Notifier for managing calories calculator state
class CaloriesCalculatorNotifier extends Notifier<CaloriesCalculatorState> {
  late final CaloriesCalculatorRepo _repo;

  @override
  CaloriesCalculatorState build() {
    _repo = ref.read(caloriesCalculatorRepo);
    // Load saved data asynchronously after build completes
    Future.microtask(() => _loadSavedData());
    return CaloriesCalculatorState();
  }

  /// Calculate calories and macros based on user input
  Future<void> calculate(UserDataModel userData) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Perform calculations
      final results = _repo.calculateResults(userData);

      // Save data for persistence
      await _repo.saveUserData(userData);

      state = state.copyWith(
        userData: userData,
        results: results,
        isLoading: false,
        hasCalculated: true,
      );

      TalkerService.info(
        'Calculation completed successfully',
        'CALORIES_CALCULATOR',
      );
    } catch (e) {
      TalkerService.error('Error during calculation', 'CALORIES_CALCULATOR', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to calculate. Please check your inputs.',
      );
    }
  }

  /// Reset calculator (clear all data)
  Future<void> reset() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repo.clearUserData();

      state = CaloriesCalculatorState(isLoading: false);

      TalkerService.info(
          'Calculator reset successfully', 'CALORIES_CALCULATOR');
    } catch (e) {
      TalkerService.error(
          'Error resetting calculator', 'CALORIES_CALCULATOR', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset calculator',
      );
    }
  }

  /// Load saved data on initialization
  Future<void> _loadSavedData() async {
    try {
      state = state.copyWith(isLoading: true);
      final userData = await _repo.loadUserData();

      if (userData != null) {
        final results = _repo.calculateResults(userData);
        state = state.copyWith(
          userData: userData,
          results: results,
          isLoading: false,
          hasCalculated: true,
        );
        TalkerService.info(
          'Loaded saved data and recalculated',
          'CALORIES_CALCULATOR',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      TalkerService.error(
        'Error loading saved data',
        'CALORIES_CALCULATOR',
        e,
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load saved data',
      );
    }
  }
}

/// State for the calories calculator
class CaloriesCalculatorState {
  final UserDataModel? userData;
  final CaloriesResultModel? results;
  final bool isLoading;
  final String? error;
  final bool hasCalculated;

  CaloriesCalculatorState({
    this.userData,
    this.results,
    this.isLoading = false,
    this.error,
    this.hasCalculated = false,
  });

  CaloriesCalculatorState copyWith({
    UserDataModel? userData,
    CaloriesResultModel? results,
    bool? isLoading,
    String? error,
    bool? hasCalculated,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return CaloriesCalculatorState(
      userData: userData ?? this.userData,
      results: clearResults ? null : (results ?? this.results),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasCalculated: hasCalculated ?? this.hasCalculated,
    );
  }
}

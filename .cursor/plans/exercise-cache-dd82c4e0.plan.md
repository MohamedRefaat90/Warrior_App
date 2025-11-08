<!-- dd82c4e0-16de-4f19-a381-9b42acbee0b5 9cb8b5b1-35a6-432d-a005-21fcb29c90ea -->
# Exercise Cache Manager Enhancement Plan

## Problem Analysis

### Critical Issues

1. **UI Blocking**: `preloadAndSaveData()` is called synchronously in the build method without await, blocking the UI thread during heavy download operations
2. **Code Duplication**: Same caching pattern repeated 3 times for image, targetedMuscles, and video
3. **No Error Recovery**: Generic exception handling without retry mechanism or specific error handling
4. **Sequential Processing**: Exercises are processed one-by-one instead of in parallel batches
5. **Poor User Feedback**: No visual indication of download status or progress

### Architecture Issues

1. **Tight Coupling**: DataManager is directly coupled to ExerciseModel
2. **Single Responsibility Violation**: Handles both caching AND Hive storage
3. **No State Management**: No way to track download progress or cache status
4. **Missing Abstraction**: Uses concrete DefaultCacheManager directly

## Solution Overview

### Core Components

1. **ExerciseCacheManager** - Refactored cache manager with parallel processing and proper error handling
2. **CacheState Provider** - Riverpod state management for tracking download progress and cache status
3. **Download Indicator Widget** - Fancy overlay banner showing offline availability on exercise cards
4. **Global Progress Indicator** - Bottom snackbar showing overall download progress

## Implementation Steps

### 1. Create Enhanced Cache Manager

**File**: `lib/core/services/exercise_cache_manager.dart` (new file)

- Implement `ExerciseCacheManager` class with dependency injection support
- Add batch processing with configurable concurrency (default 3 concurrent downloads)
- Implement `_cacheMedia()` method with duplicate download prevention
- Add cache validation checking if all assets exist
- Implement proper error handling with detailed logging levels
- Add utility methods: `clearCache()`, `getCacheSize()`, `isCached()`
- Use `Stream<CacheProgress>` for real-time progress updates

### 2. Create Cache State Management

**File**: `lib/core/providers/cache_provider.dart` (new file)

Define state models:

```dart
class CacheProgress {
  final int totalExercises;
  final int cachedExercises;
  final int failedExercises;
  final CacheStatus status;
  final String? currentExercise;
}

enum CacheStatus { idle, downloading, completed, failed }
```

Create Riverpod providers:

- `exerciseCacheManagerProvider` - Singleton cache manager instance
- `cacheProgressProvider` - StateNotifier for download progress
- `exerciseCacheStatusProvider(exerciseId)` - Family provider for individual exercise status

### 3. Create Download Indicator Widget

**File**: `lib/features/Exercises/presentation/widgets/download_indicator.dart` (new file)

Design specifications:

- Overlay banner positioned at top right of exercise card
- Semi-transparent gradient background (red theme matching app colors)
- States:
  - **Not Downloaded**: No indicator shown
  - **Downloading**: Animated shimmer effect with cloud download icon
  - **Downloaded**: Static banner with checkmark icon and "Available Offline" text
- Use `flutter_animate` package for smooth animations
- Match app's design system (elevation 5, rounded corners, shadow effects)

Widget structure:

```dart
class DownloadIndicatorBanner extends StatelessWidget {
  final ExerciseModel exercise;
  final CacheStatus status;
  
  // Returns banner with icon + text based on status
  // Uses gradient from AppColors.primaryColor with opacity
  // Animated entry/exit with slide and fade
}
```

### 4. Update Exercise Card

**File**: `lib/features/Exercises/presentation/widgets/exercise_card.dart`

Modifications:

- Add `ConsumerStatefulWidget` if not already (already is ConsumerStatefulWidget ✓)
- Watch `exerciseCacheStatusProvider(exercise.id)` 
- Add `DownloadIndicatorBanner` as positioned widget in Stack (line 37-103)
- Position banner at `bottom: 0, left: 0, right: 0`
- Ensure banner doesn't interfere with checkbox in select mode

### 5. Create Global Progress Widget

**File**: `lib/features/Exercises/presentation/widgets/download_progress_indicator.dart` (new file)

Design specifications:

- Animated slide-up snackbar from bottom
- Show when `cacheProgressProvider.status == downloading`
- Display: "Downloading exercises: X/Y" with linear progress bar
- Use `AnimatedContainer` for smooth transitions
- Auto-dismiss when complete with success message
- Match app's card style with elevation and shadows
- Use `flutter_animate` for entrance animation

### 6. Update Exercises Screen

**File**: `lib/features/Exercises/presentation/screens/exercises_screen.dart`

Changes at line 48-50:

```dart
data: (exercises) {
  // Start async caching without blocking UI
  ref.read(cacheProgressProvider.notifier).startCaching(
    exercises: exercises,
    box: HiveManager.exercisesBox,
  );
  
  return Stack(
    children: [
      ExercisesGridView(...),
      // Global progress indicator overlay
      const DownloadProgressIndicator(),
    ],
  );
}
```

### 7. Update ExercisesGridView

**File**: `lib/features/Exercises/presentation/widgets/exercises_gridview.dart`

- Wrap with Stack if adding global progress overlay
- No other changes needed - cards will automatically show indicators

### 8. Package Dependencies

**File**: `pubspec.yaml`

Add packages:

- `flutter_animate: ^4.5.0` - For smooth animations on indicators
- Consider  skeletonizer: ^2.1.0+1 for downloading skeletonizer effect

### 9. Delete Old Cache Manager

**File**: `lib/core/services/cache_manager.dart`

- Mark as deprecated or delete after migration complete
- Update all imports to use new `ExerciseCacheManager`

## Key Improvements Summary

### Performance

- Parallel batch processing (3 concurrent downloads)
- Smart cache validation avoiding redundant downloads
- Duplicate download prevention via pending operations map
- Non-blocking async operations

### Reliability  

- Proper error handling with specific exceptions
- Partial success tracking
- Validation ensuring all assets cached before Hive write
- Race condition prevention

### User Experience

- Real-time visual feedback with download indicators
- Global progress tracking with percentage
- Fancy overlay banner matching app theme
- Smooth animations for status changes

### Code Quality

- Single Responsibility Principle compliance
- DRY - no code duplication
- Testable with dependency injection
- Clear separation of concerns
- Comprehensive documentation

## Testing Considerations

- Unit tests for `ExerciseCacheManager` with mock CacheManager
- Widget tests for `DownloadIndicatorBanner` states
- Integration tests for complete download flow
- Test offline/online mode switching
- Test error scenarios and recovery

### To-dos

- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
- [ ] Create new ExerciseCacheManager with parallel processing, error handling, and progress streaming
- [ ] Create Riverpod providers for cache state management (progress, status per exercise)
- [ ] Create DownloadIndicatorBanner widget with overlay banner design and animations
- [ ] Create DownloadProgressIndicator widget for global progress snackbar
- [ ] Update ExerciseCard to include DownloadIndicatorBanner with status tracking
- [ ] Update ExercisesScreen to use new cache manager and show global progress
- [ ] Add flutter_animate package to pubspec.yaml
- [ ] Remove old DataManager class and update all imports
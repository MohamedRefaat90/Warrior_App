# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> The parent directory also has a `CLAUDE.md` with commands, conventions, and backend notes. This file adds Flutter app-specific architecture depth.

---

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=secrets.json
flutter test
flutter test test/unit/some_test.dart   # single file
flutter analyze
dart format lib/
```

Run build_runner after any change to a file annotated with `@HiveType`, `@JsonSerializable`, or `@riverpod`.

---

## Offline-First Sync Architecture

This is the most non-obvious part of the codebase. Every mutating workout operation writes **immediately to Hive** (optimistic local update) and, if offline, queues a `PendingOperation` for later sync.

### Key files

| File | Role |
|------|------|
| `lib/core/services/hive_boxes.dart` | `HiveManager` — all Hive box handles + `deduplicatePendingOps()` |
| `lib/core/services/sync.dart` | `SyncService` (Riverpod Notifier) — syncs pending ops on connect/startup |
| `lib/features/Workouts/data/models/pending_operations_model.dart` | `PendingOperation` / `SyncOperationType` Hive models |
| `lib/core/network/cache_status_repository.dart` | Lightweight `/cache-status/` endpoint — avoids full re-fetches |
| `lib/core/services/cache_metadata_service.dart` | Persists last_updated + count to SharedPrefs for cache invalidation |

### Hive box inventory (type IDs matter — never reuse)

| Box name | Type | typeId |
|----------|------|--------|
| `workouts` | `WorkoutSetModel` | 3 |
| `predefinedWorkouts` | `WorkoutSetModel` | 3 |
| `pendingOperations` | `PendingOperation` | 5 |
| `muscles` | `MuscleModel` | 1 |
| `exercises` | `ExerciseModel` | 0 |
| `foodProducts` | `FoodProductModel` | — |
| `pendingProducts` | `PendingProductUpload` | — |

All adapters are registered in `HiveManager.init()` **and** auto-generated in `lib/hive_registrar.g.dart`. Both must stay in sync.

### PendingOperation entity types

`entityType` is a plain string — valid values: `'workout'`, `'workout_weight'`, `'workout_sets'`.

`SyncOperationType` enum: `create`, `update`, `delete`, `reorder`.

### Sync flow

1. `SyncService.build()` calls `_initSync()` which waits 2 s then auto-syncs if there are pending ops.
2. `syncPendingOperations()` deduplicates ops (`HiveManager.deduplicatePendingOps()`), processes in timestamp order, deletes only successfully applied keys.
3. After any `create` op, the full workout list is re-fetched to replace local Hive IDs with server-assigned IDs.
4. Failed ops stay in the queue for retry on next sync.

### Deduplication rules (in `deduplicatePendingOps`)

- If a workout has a `delete` op, all prior `create`/`update` ops for the same workout are removed.
- For the same entity+workout+exercise, only the latest `update` op is kept.
- For `reorder`, only the latest is kept.

---

## Cache Invalidation Pattern

Used for muscles and predefined workouts (large, infrequently changed datasets):

1. On screen load, `CacheStatusRepository.fetchCacheStatus()` hits a tiny `/cache-status/` endpoint (~100 bytes, server-cached 5 min).
2. `CacheMetadataService.needsRefresh()` compares `last_updated` + `count` against SharedPrefs.
3. Only if changed (or first launch) does the feature repo fetch the full dataset and update Hive + metadata.

This avoids redundant full re-fetches on every navigation.

---

## Riverpod Provider Pattern

All providers follow the same shape. Always check the provider declaration before changing the notifier base class:

```dart
// autoDispose → notifier extends AutoDisposeNotifier
final myProvider = NotifierProvider.autoDispose<MyNotifier, State>(MyNotifier.new);
class MyNotifier extends AutoDisposeNotifier<State> { ... }

// regular → notifier extends Notifier
final myProvider = NotifierProvider<MyNotifier, State>(MyNotifier.new);
class MyNotifier extends Notifier<State> { ... }
```

`workoutsProvider` uses plain `NotifierProvider` (not autoDispose) because the workout list must survive navigation.

---

## Localization

Hardcoded strings are forbidden. Access via `.tr()` extension (from `lib/core/extensions/translation_ext.dart`) or `context.l10n`. ARB files at `lib/core/localization/arb/en.arb` and `ar.arb` must always be updated together.

Muscle group translations live in `lib/core/localization/muscle_translations.dart` as a separate static map (not ARB), because muscle names are data-driven.

---

## Ad System

- `BannerAdWidget` / `NativeAdWidget` are `ConsumerStatefulWidget` — they read `systemSettingsProvider` internally and return `SizedBox.shrink()` when `showAds` is false.
- `InterstitialAdManager.showAds` is a static flag that must be set **before** `loadAd()`.
- `AppOpenAdManager.showAdIfAvailable()` requires passing `ref.read(systemSettingsProvider).showAds`.

---

## CI/CD Workflows

Located in `.github/workflows/`:

| Workflow | Trigger |
|----------|---------|
| `tests.yaml` | Every push — Flutter test + analyze |
| `android_fastlane_firebaseDistribution.yaml` | Manual — Firebase App Distribution |
| `shorebird_deploy.yaml` | Manual — OTA patch via Shorebird |
| `google_play_store.yaml` | Manual — Play Store publish |

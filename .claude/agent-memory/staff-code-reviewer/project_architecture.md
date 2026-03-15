---
name: project_architecture
description: Key patterns in the Warrior Flutter app — cache strategy, provider conventions, SharedPref null safety issues, ConnectivityChecker global state
type: project
---

- `SharedPref` uses `prefs!` force-unwrap on every getter/setter. If called before `SharedPref.init()`, it will throw. `CacheMetadataService.needsRefresh()` relies on `SharedPref.getString/getInt` which both force-unwrap `prefs!`.
- `ConnectivityChecker.isOnline` is a nullable static `bool?`. Many call sites use `isOnline!` which will throw if `isOnline` is still null (before initialization). The PR introduces safer `?? false` patterns in new code, but old code like `muscles_screen.dart` still uses `isOnline!`.
- `TalkerService` has a guard `if (!_isInitialized) return;` on all log methods, so calling before init is safe (no-ops).
- `AppServices.init()` calls `TalkerService.init()` first, then SharedPref, Dio, Hive in order. So `TalkerService.warning` in `main()` catch block runs before `TalkerService.init()` and silently no-ops.
- `musclesProvider` changed from `FutureProvider.autoDispose` to `AsyncNotifierProvider` (non-autoDispose). This is a breaking change for any code using `ref.invalidate(musclesProvider)` or watching it with auto-dispose semantics.
- `HiveManager.saveToHive` uses `box.clear()` then `box.put(i, data[i])` in a loop — not atomic.

**Why:** Understanding these patterns helps review cache-related PRs and catch null-safety or initialization-order bugs.
**How to apply:** When reviewing cache/provider changes, verify initialization order and null-safety of static singletons.

import 'package:flutter/material.dart';

import 'arb/app_localizations.dart';

/// Translates muscle names from API (English) to the current locale
String translateMuscleName(BuildContext context, String muscleName) {
  final l10n = AppLocalizations.of(context)!;

  // Normalize the muscle name to lowercase for comparison
  final normalized = muscleName.toLowerCase().trim();

  return switch (normalized) {
    'abs' => l10n.muscleAbs,
    'triceps' => l10n.muscleTriceps,
    'shoulders' => l10n.muscleShoulders,
    'legs' => l10n.muscleLegs,
    'chest' => l10n.muscleChest,
    'biceps' => l10n.muscleBiceps,
    'back' => l10n.muscleBack,
    'forearms' => l10n.muscleForearms,
    'glutes' => l10n.muscleGlutes,
    'calves' => l10n.muscleCalves,
    'core' => l10n.muscleCore,
    'traps' => l10n.muscleTraps,
    _ => muscleName, // Return original if not found
  };
}

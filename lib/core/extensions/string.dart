extension StringExtensions on String {
  String capitalizeWord() {
    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  bool isNull() {
    return false;
  }

  String removeExtraSpaces() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

/// Extension on String to provide .tr translation method
/// This allows for a cleaner syntax when using translation keys
// extension TranslationExtension on String {
//   /// Translates the string key using the current locale
//   ///
//   /// Usage: 'appTitle'.tr(context)
//   ///
//   /// This is a convenience method that maps string keys to
//   /// AppLocalizations getters. For better type safety and
//   /// IDE autocomplete, use context.l10n.keyName instead.
//   String tr(BuildContext context) {
//     final localizations = AppLocalizations.of(context)!;

//     // Map string keys to AppLocalizations getters
//     switch (this) {
//       case 'appTitle':
//         return localizations.appTitle;
//       case 'darkMode':
//         return localizations.darkMode;
//       case 'language':
//         return localizations.language;
//       case 'unleashYourPower':
//         return localizations.unleashYourPower;
//       case 'shareApp':
//         return localizations.shareApp;
//       case 'spreadTheWarriorSpirit':
//         return localizations.spreadTheWarriorSpirit;
//       case 'rateApp':
//         return localizations.rateApp;
//       case 'supportUs':
//         return localizations.supportUs;
//       case 'logout':
//         return localizations.logout;
//       case 'takeARest':
//         return localizations.takeARest;
//       case 'version':
//         return localizations.version;
//       case 'shareAppMessage':
//         return localizations.shareAppMessage;
//       case 'settings':
//         return localizations.settings;
//       case 'english':
//         return localizations.english;
//       case 'arabic':
//         return localizations.arabic;
//       case 'cancel':
//         return localizations.cancel;
//       case 'delete':
//         return localizations.delete;
//       case 'edit':
//         return localizations.edit;
//       case 'save':
//         return localizations.save;
//       case 'create':
//         return localizations.create;
//       case 'retry':
//         return localizations.retry;
//       case 'start':
//         return localizations.start;
//       case 'comingSoon':
//         return localizations.comingSoon;
//       case 'createWorkoutSet':
//         return localizations.createWorkoutSet;
//       case 'editWorkoutSet':
//         return localizations.editWorkoutSet;
//       case 'searchHistory':
//         return localizations.searchHistory;
//       case 'clearHistory':
//         return localizations.clearHistory;
//       case 'supplementsScreen':
//         return localizations.supplementsScreen;
//       case 'nutritionScreen':
//         return localizations.nutritionScreen;

//       // Add more cases as you add more translations to ARB files

//       default:
//         // Return the key itself if not found (for development)
//         return this;
//     }
//   }
// }

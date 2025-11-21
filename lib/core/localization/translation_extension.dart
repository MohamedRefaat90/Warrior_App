import 'package:flutter/widgets.dart';

import 'arb/app_localizations.dart';

/// Extension on BuildContext to provide easy access to AppLocalizations
extension LocalizationContext on BuildContext {
  /// Quick access to AppLocalizations
  ///
  /// Usage: context.l10n.appTitle
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Extension on String to provide .tr translation method
/// This allows for a cleaner syntax when using translation keys
extension TranslationExtension on String {
  /// Translates the string key using the current locale
  ///
  /// Usage: 'appTitle'.tr(context)
  ///
  /// This is a convenience method that maps string keys to
  /// AppLocalizations getters. For better type safety and
  /// IDE autocomplete, use context.l10n.keyName instead.
  String tr(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Map string keys to AppLocalizations getters
    switch (this) {
      // App & Settings
      case 'appTitle':
        return localizations.appTitle;
      case 'darkMode':
        return localizations.darkMode;
      case 'language':
        return localizations.language;
      case 'settings':
        return localizations.settings;
      case 'english':
        return localizations.english;
      case 'arabic':
        return localizations.arabic;

      // Drawer Menu
      case 'unleashYourPower':
        return localizations.unleashYourPower;
      case 'shareApp':
        return localizations.shareApp;
      case 'spreadTheWarriorSpirit':
        return localizations.spreadTheWarriorSpirit;
      case 'rateApp':
        return localizations.rateApp;
      case 'supportUs':
        return localizations.supportUs;
      case 'logout':
        return localizations.logout;
      case 'takeARest':
        return localizations.takeARest;
      case 'version':
        return localizations.version;
      case 'shareAppMessage':
        return localizations.shareAppMessage;

      // Common Actions
      case 'cancel':
        return localizations.cancel;
      case 'delete':
        return localizations.delete;
      case 'edit':
        return localizations.edit;
      case 'save':
        return localizations.save;
      case 'create':
        return localizations.create;
      case 'retry':
        return localizations.retry;
      case 'start':
        return localizations.start;
      case 'search':
        return localizations.search;
      case 'clear':
        return localizations.clear;

      // Screens & Features
      case 'comingSoon':
        return localizations.comingSoon;
      case 'supplementsScreen':
        return localizations.supplementsScreen;
      case 'nutritionScreen':
        return localizations.nutritionScreen;

      // Workouts
      case 'createWorkoutSet':
        return localizations.createWorkoutSet;
      case 'editWorkoutSet':
        return localizations.editWorkoutSet;
      case 'deleteWorkout':
        return localizations.deleteWorkout;

      // Search History
      case 'searchHistory':
        return localizations.searchHistory;
      case 'clearHistory':
        return localizations.clearHistory;

      // Onboarding
      case 'letsBegin':
        return localizations.letsBegin;

      // Food Search
      case 'scanBarcode':
        return localizations.scanBarcode;
      case 'productNotFound':
        return localizations.productNotFound;
      case 'addProduct':
        return localizations.addProduct;
      case 'enterBarcode':
        return localizations.enterBarcode;
      case 'understandingFoodScores':
        return localizations.understandingFoodScores;
      case 'vegan':
        return localizations.vegan;
      case 'vegetarian':
        return localizations.vegetarian;
      case 'palmOilFree':
        return localizations.palmOilFree;
      case 'nutriScore':
        return localizations.nutriScore;
      case 'foodSearch':
        return localizations.foodSearch;
      case 'scan':
        return localizations.scan;
      case 'compareProducts':
        return localizations.compareProducts;
      case 'addAnotherProduct':
        return localizations.addAnotherProduct;
      case 'na':
        return localizations.na;
      case 'favorites':
        return localizations.favorites;
      case 'advancedSearch':
        return localizations.advancedSearch;
      case 'veganOnly':
        return localizations.veganOnly;
      case 'vegetarianOnly':
        return localizations.vegetarianOnly;

      // Nutrition Guide
      case 'makeBetterFoodChoices':
        return localizations.makeBetterFoodChoices;
      case 'learnAboutScores':
        return localizations.learnAboutScores;
      case 'nutriScoreLong':
        return localizations.nutriScoreLong;
      case 'nutriScoreDescription':
        return localizations.nutriScoreDescription;
      case 'howItWorks':
        return localizations.howItWorks;
      case 'nutriScorePoint1':
        return localizations.nutriScorePoint1;
      case 'nutriScorePoint2':
        return localizations.nutriScorePoint2;
      case 'nutriScorePoint3':
        return localizations.nutriScorePoint3;
      case 'scoreGuide':
        return localizations.scoreGuide;
      case 'excellentQuality':
        return localizations.excellentQuality;
      case 'scoreAExamples':
        return localizations.scoreAExamples;
      case 'goodQuality':
        return localizations.goodQuality;
      case 'scoreBExamples':
        return localizations.scoreBExamples;
      case 'averageQuality':
        return localizations.averageQuality;
      case 'scoreCExamples':
        return localizations.scoreCExamples;
      case 'poorQuality':
        return localizations.poorQuality;
      case 'scoreDExamples':
        return localizations.scoreDExamples;
      case 'veryPoorQuality':
        return localizations.veryPoorQuality;
      case 'scoreEExamples':
        return localizations.scoreEExamples;
      case 'novaClassification':
        return localizations.novaClassification;
      case 'novaDescription':
        return localizations.novaDescription;
      case 'novaGroup1':
        return localizations.novaGroup1;
      case 'novaGroup2':
        return localizations.novaGroup2;
      case 'novaGroup3':
        return localizations.novaGroup3;
      case 'novaGroup4':
        return localizations.novaGroup4;
      case 'unprocessedMinimal':
        return localizations.unprocessedMinimal;
      case 'nova1Examples':
        return localizations.nova1Examples;
      case 'culinaryIngredients':
        return localizations.culinaryIngredients;
      case 'nova2Examples':
        return localizations.nova2Examples;
      case 'processedFoods':
        return localizations.processedFoods;
      case 'nova3Examples':
        return localizations.nova3Examples;
      case 'ultraProcessed':
        return localizations.ultraProcessed;
      case 'nova4Examples':
        return localizations.nova4Examples;
      case 'ecoScore':
        return localizations.ecoScore;
      case 'ecoScoreDescription':
        return localizations.ecoScoreDescription;
      case 'ecoPoint1':
        return localizations.ecoPoint1;
      case 'ecoPoint2':
        return localizations.ecoPoint2;
      case 'ecoPoint3':
        return localizations.ecoPoint3;
      case 'ecoPoint4':
        return localizations.ecoPoint4;
      case 'veryLowImpact':
        return localizations.veryLowImpact;
      case 'ecoAExamples':
        return localizations.ecoAExamples;
      case 'lowImpact':
        return localizations.lowImpact;
      case 'ecoBExamples':
        return localizations.ecoBExamples;
      case 'moderateImpact':
        return localizations.moderateImpact;
      case 'ecoCExamples':
        return localizations.ecoCExamples;
      case 'highImpact':
        return localizations.highImpact;
      case 'ecoDExamples':
        return localizations.ecoDExamples;
      case 'veryHighImpact':
        return localizations.veryHighImpact;
      case 'ecoEExamples':
        return localizations.ecoEExamples;
      case 'quickTips':
        return localizations.quickTips;
      case 'tip1':
        return localizations.tip1;
      case 'tip2':
        return localizations.tip2;
      case 'tip3':
        return localizations.tip3;
      case 'tip4':
        return localizations.tip4;
      case 'tip5':
        return localizations.tip5;

      // Add more cases as you add more translations to ARB files

      default:
        // Return the key itself if not found (for development)
        return this;
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get appTitle;

  /// Label for dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Label for language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Tagline in drawer header
  ///
  /// In en, this message translates to:
  /// **'💪 Unleash Your Power'**
  String get unleashYourPower;

  /// Share app menu item
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// Subtitle for share app
  ///
  /// In en, this message translates to:
  /// **'Spread the warrior spirit'**
  String get spreadTheWarriorSpirit;

  /// Rate app menu item
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// Subtitle for rate app
  ///
  /// In en, this message translates to:
  /// **'Support Us ⭐'**
  String get supportUs;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Subtitle for logout
  ///
  /// In en, this message translates to:
  /// **'Take a rest warrior'**
  String get takeARest;

  /// Version label in drawer footer
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Message shown when sharing the app
  ///
  /// In en, this message translates to:
  /// **'Check out the Warrior App for amazing workout routines! Download it here: https://play.google.com/store/apps/details?id=com.warrior90.app'**
  String get shareAppMessage;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Coming soon placeholder text
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Create workout set button text
  ///
  /// In en, this message translates to:
  /// **'Create Workout Set'**
  String get createWorkoutSet;

  /// Edit workout set dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Workout Set'**
  String get editWorkoutSet;

  /// Search history screen title
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistory;

  /// Clear history button text
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Supplements screen title
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get supplementsScreen;

  /// Nutrition screen title
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionScreen;

  /// Delete workout confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete Workout?'**
  String get deleteWorkout;

  /// Onboarding begin button
  ///
  /// In en, this message translates to:
  /// **'Let\'s Begin'**
  String get letsBegin;

  /// Scan barcode screen title
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// Product not found message
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get productNotFound;

  /// Add product button
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Enter barcode dialog title
  ///
  /// In en, this message translates to:
  /// **'Enter Barcode'**
  String get enterBarcode;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Food scores guide title
  ///
  /// In en, this message translates to:
  /// **'Understanding Food Scores'**
  String get understandingFoodScores;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Vegan label
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// Vegetarian label
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// Palm oil free label
  ///
  /// In en, this message translates to:
  /// **'Palm Oil Free'**
  String get palmOilFree;

  /// Nutri-Score label
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score'**
  String get nutriScore;

  /// Food search screen title
  ///
  /// In en, this message translates to:
  /// **'Food Search'**
  String get foodSearch;

  /// Scan button text
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Compare products screen title
  ///
  /// In en, this message translates to:
  /// **'Compare Products'**
  String get compareProducts;

  /// Add another product button
  ///
  /// In en, this message translates to:
  /// **'Add Another Product'**
  String get addAnotherProduct;

  /// Not available abbreviation
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// Favorites screen title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Advanced search screen title
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get advancedSearch;

  /// Vegan only filter
  ///
  /// In en, this message translates to:
  /// **'Vegan Only'**
  String get veganOnly;

  /// Vegetarian only filter
  ///
  /// In en, this message translates to:
  /// **'Vegetarian Only'**
  String get vegetarianOnly;

  /// Nutrition guide hero title
  ///
  /// In en, this message translates to:
  /// **'Make Better Food Choices'**
  String get makeBetterFoodChoices;

  /// Nutrition guide hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Learn about the scores that help you understand food quality'**
  String get learnAboutScores;

  /// Nutri-Score section title
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score'**
  String get nutriScoreLong;

  /// Nutri-Score description
  ///
  /// In en, this message translates to:
  /// **'A nutrition quality indicator that rates foods from A (best) to E (worst) based on their nutritional value.'**
  String get nutriScoreDescription;

  /// How it works section title
  ///
  /// In en, this message translates to:
  /// **'How it works:'**
  String get howItWorks;

  /// Nutri-Score explanation point 1
  ///
  /// In en, this message translates to:
  /// **'Considers positive nutrients: fiber, protein, fruits & vegetables'**
  String get nutriScorePoint1;

  /// Nutri-Score explanation point 2
  ///
  /// In en, this message translates to:
  /// **'Considers negative nutrients: calories, saturated fat, sugar, salt'**
  String get nutriScorePoint2;

  /// Nutri-Score explanation point 3
  ///
  /// In en, this message translates to:
  /// **'The balance determines the final score'**
  String get nutriScorePoint3;

  /// Score guide section title
  ///
  /// In en, this message translates to:
  /// **'Score Guide:'**
  String get scoreGuide;

  /// Score A description
  ///
  /// In en, this message translates to:
  /// **'Excellent nutritional quality'**
  String get excellentQuality;

  /// Score A examples
  ///
  /// In en, this message translates to:
  /// **'Vegetables, fruits, whole grains'**
  String get scoreAExamples;

  /// Score B description
  ///
  /// In en, this message translates to:
  /// **'Good nutritional quality'**
  String get goodQuality;

  /// Score B examples
  ///
  /// In en, this message translates to:
  /// **'Yogurt, fish, nuts'**
  String get scoreBExamples;

  /// Score C description
  ///
  /// In en, this message translates to:
  /// **'Average nutritional quality'**
  String get averageQuality;

  /// Score C examples
  ///
  /// In en, this message translates to:
  /// **'Bread, pasta, some cereals'**
  String get scoreCExamples;

  /// Score D description
  ///
  /// In en, this message translates to:
  /// **'Poor nutritional quality'**
  String get poorQuality;

  /// Score D examples
  ///
  /// In en, this message translates to:
  /// **'Cookies, cakes, processed foods'**
  String get scoreDExamples;

  /// Score E description
  ///
  /// In en, this message translates to:
  /// **'Very poor nutritional quality'**
  String get veryPoorQuality;

  /// Score E examples
  ///
  /// In en, this message translates to:
  /// **'Soft drinks, chips, candy'**
  String get scoreEExamples;

  /// NOVA section title
  ///
  /// In en, this message translates to:
  /// **'NOVA Classification'**
  String get novaClassification;

  /// NOVA description
  ///
  /// In en, this message translates to:
  /// **'A food classification system based on the extent and purpose of food processing.'**
  String get novaDescription;

  /// NOVA group 1 description
  ///
  /// In en, this message translates to:
  /// **'Group 1: Unprocessed or minimally processed foods'**
  String get novaGroup1;

  /// NOVA group 2 description
  ///
  /// In en, this message translates to:
  /// **'Group 2: Processed culinary ingredients'**
  String get novaGroup2;

  /// NOVA group 3 description
  ///
  /// In en, this message translates to:
  /// **'Group 3: Processed foods'**
  String get novaGroup3;

  /// NOVA group 4 description
  ///
  /// In en, this message translates to:
  /// **'Group 4: Ultra-processed foods'**
  String get novaGroup4;

  /// NOVA group 1 label
  ///
  /// In en, this message translates to:
  /// **'Unprocessed/Minimally'**
  String get unprocessedMinimal;

  /// NOVA group 1 examples
  ///
  /// In en, this message translates to:
  /// **'Fresh fruits, vegetables, meat, eggs'**
  String get nova1Examples;

  /// NOVA group 2 label
  ///
  /// In en, this message translates to:
  /// **'Culinary Ingredients'**
  String get culinaryIngredients;

  /// NOVA group 2 examples
  ///
  /// In en, this message translates to:
  /// **'Oils, butter, sugar, salt'**
  String get nova2Examples;

  /// NOVA group 3 label
  ///
  /// In en, this message translates to:
  /// **'Processed Foods'**
  String get processedFoods;

  /// NOVA group 3 examples
  ///
  /// In en, this message translates to:
  /// **'Canned vegetables, cheese, bread'**
  String get nova3Examples;

  /// NOVA group 4 label
  ///
  /// In en, this message translates to:
  /// **'Ultra-Processed'**
  String get ultraProcessed;

  /// NOVA group 4 examples
  ///
  /// In en, this message translates to:
  /// **'Soft drinks, instant noodles, packaged snacks'**
  String get nova4Examples;

  /// Eco-Score section title
  ///
  /// In en, this message translates to:
  /// **'Eco-Score'**
  String get ecoScore;

  /// Eco-Score description
  ///
  /// In en, this message translates to:
  /// **'An environmental impact indicator that rates foods from A (best) to E (worst) based on their ecological footprint.'**
  String get ecoScoreDescription;

  /// Eco-Score explanation point 1
  ///
  /// In en, this message translates to:
  /// **'Considers production methods and origin'**
  String get ecoPoint1;

  /// Eco-Score explanation point 2
  ///
  /// In en, this message translates to:
  /// **'Evaluates transportation and packaging'**
  String get ecoPoint2;

  /// Eco-Score explanation point 3
  ///
  /// In en, this message translates to:
  /// **'Accounts for environmental policies'**
  String get ecoPoint3;

  /// Eco-Score explanation point 4
  ///
  /// In en, this message translates to:
  /// **'Measures carbon footprint and biodiversity impact'**
  String get ecoPoint4;

  /// Eco-Score A description
  ///
  /// In en, this message translates to:
  /// **'Very low environmental impact'**
  String get veryLowImpact;

  /// Eco-Score A examples
  ///
  /// In en, this message translates to:
  /// **'Local organic vegetables'**
  String get ecoAExamples;

  /// Eco-Score B description
  ///
  /// In en, this message translates to:
  /// **'Low environmental impact'**
  String get lowImpact;

  /// Eco-Score B examples
  ///
  /// In en, this message translates to:
  /// **'Seasonal fruits, legumes'**
  String get ecoBExamples;

  /// Eco-Score C description
  ///
  /// In en, this message translates to:
  /// **'Moderate environmental impact'**
  String get moderateImpact;

  /// Eco-Score C examples
  ///
  /// In en, this message translates to:
  /// **'Dairy products, poultry'**
  String get ecoCExamples;

  /// Eco-Score D description
  ///
  /// In en, this message translates to:
  /// **'High environmental impact'**
  String get highImpact;

  /// Eco-Score D examples
  ///
  /// In en, this message translates to:
  /// **'Imported foods, red meat'**
  String get ecoDExamples;

  /// Eco-Score E description
  ///
  /// In en, this message translates to:
  /// **'Very high environmental impact'**
  String get veryHighImpact;

  /// Eco-Score E examples
  ///
  /// In en, this message translates to:
  /// **'Air-freighted foods, intensive farming'**
  String get ecoEExamples;

  /// Tips section title
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quickTips;

  /// Tip 1
  ///
  /// In en, this message translates to:
  /// **'Aim for Nutri-Score A or B products'**
  String get tip1;

  /// Tip 2
  ///
  /// In en, this message translates to:
  /// **'Choose NOVA Group 1 or 2 when possible'**
  String get tip2;

  /// Tip 3
  ///
  /// In en, this message translates to:
  /// **'Prefer Eco-Score A or B for the planet'**
  String get tip3;

  /// Tip 4
  ///
  /// In en, this message translates to:
  /// **'Read ingredient lists, not just scores'**
  String get tip4;

  /// Tip 5
  ///
  /// In en, this message translates to:
  /// **'Balance is key - variety in your diet matters'**
  String get tip5;

  /// Advanced search tooltip
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get advancedSearchTooltip;

  /// Search history tooltip
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistoryTooltip;

  /// Add product button label
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductButton;

  /// Favorites button label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesButton;

  /// Compare button label
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareButton;

  /// Recently scanned section title
  ///
  /// In en, this message translates to:
  /// **'Recently Scanned'**
  String get recentlyScanned;

  /// No products empty state title
  ///
  /// In en, this message translates to:
  /// **'No Products Yet'**
  String get noProductsYet;

  /// No products empty state message
  ///
  /// In en, this message translates to:
  /// **'Start by scanning a barcode or searching for products'**
  String get startByScanningBarcode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

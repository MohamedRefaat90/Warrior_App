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

  /// Description of the food search feature shown in a dialog
  ///
  /// In en, this message translates to:
  /// **'Discover nutritional facts, scan barcodes, and compare products to fuel your warrior journey with the right nutrition.'**
  String get foodSearchDescription;

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

  /// Login button and title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign up button and title
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// Email field placeholder
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Confirm password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// New password field placeholder
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Password required validation message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Name required validation message
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Forget password screen title
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgetPassword;

  /// Send email button
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Enter new password instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// Verify OTP screen title
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// OTP instruction text
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your email'**
  String get enterOtpSentToEmail;

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// Signup success message
  ///
  /// In en, this message translates to:
  /// **'Welcome warrior, you can join the battle now 💪'**
  String get welcomeWarrior;

  /// Password reset success message
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Try to login with new password'**
  String get passwordResetSuccess;

  /// No account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Login with divider text
  ///
  /// In en, this message translates to:
  /// **'Login With'**
  String get loginWith;

  /// Internet connection error message
  ///
  /// In en, this message translates to:
  /// **'Check Your Internet Connection'**
  String get checkInternetConnection;

  /// Password length validation
  ///
  /// In en, this message translates to:
  /// **'Must be larger than 8 characters'**
  String get mustBeLargerThan8;

  /// Password uppercase validation
  ///
  /// In en, this message translates to:
  /// **'Must contain uppercase character'**
  String get mustContainUpperChar;

  /// Password lowercase validation
  ///
  /// In en, this message translates to:
  /// **'Must contain lowercase character'**
  String get mustContainLowerChar;

  /// Password number validation
  ///
  /// In en, this message translates to:
  /// **'Must contain a number'**
  String get mustContainNumber;

  /// Password special character validation
  ///
  /// In en, this message translates to:
  /// **'Must contain special character'**
  String get mustContainSpecialChar;

  /// Muscles category title
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get muscles;

  /// Front body view button label
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get bodyViewFront;

  /// Back body view button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bodyViewBack;

  /// My workouts category title
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get myWorkouts;

  /// Predefined workouts category title
  ///
  /// In en, this message translates to:
  /// **'Predefined Workouts'**
  String get predefinedWorkouts;

  /// Calories calculator category title
  ///
  /// In en, this message translates to:
  /// **'Calories Calculator'**
  String get caloriesCalculator;

  /// Reset calculator tooltip
  ///
  /// In en, this message translates to:
  /// **'Reset Calculator'**
  String get resetCalculator;

  /// Calculation success message
  ///
  /// In en, this message translates to:
  /// **'Calculation completed successfully! 🎉'**
  String get calculationSuccess;

  /// Calculation error message prefix
  ///
  /// In en, this message translates to:
  /// **'Failed to calculate'**
  String get failedToCalculate;

  /// Activity level - sedentary
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// Sedentary description
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise'**
  String get sedentaryDesc;

  /// Activity level - lightly active
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get lightlyActive;

  /// Lightly active description
  ///
  /// In en, this message translates to:
  /// **'Light exercise 1-3 days/week'**
  String get lightlyActiveDesc;

  /// Activity level - moderately active
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get moderatelyActive;

  /// Moderately active description
  ///
  /// In en, this message translates to:
  /// **'Moderate exercise 3-5 days/week'**
  String get moderatelyActiveDesc;

  /// Activity level - very active
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get veryActive;

  /// Very active description
  ///
  /// In en, this message translates to:
  /// **'Hard exercise 6-7 days/week'**
  String get veryActiveDesc;

  /// Activity level - extra active
  ///
  /// In en, this message translates to:
  /// **'Extra Active'**
  String get extraActive;

  /// Extra active description
  ///
  /// In en, this message translates to:
  /// **'Very hard exercise & physical job'**
  String get extraActiveDesc;

  /// New workout button
  ///
  /// In en, this message translates to:
  /// **'New Workout'**
  String get newWorkout;

  /// Your workouts section title
  ///
  /// In en, this message translates to:
  /// **'Your Workouts'**
  String get yourWorkouts;

  /// New workout set dialog title
  ///
  /// In en, this message translates to:
  /// **'New Workout Set'**
  String get newWorkoutSet;

  /// Workout name field
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workoutName;

  /// Optional description field
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No workouts empty state title
  ///
  /// In en, this message translates to:
  /// **'No Workouts Yet'**
  String get noWorkoutsYet;

  /// No workouts empty state message
  ///
  /// In en, this message translates to:
  /// **'Start building your fitness journey by creating your first workout set!'**
  String get startBuildingFitness;

  /// Workout organization tip
  ///
  /// In en, this message translates to:
  /// **'Tip: Organize your exercises into sets for better tracking'**
  String get tipOrganizeExercises;

  /// Add exercise tooltip
  ///
  /// In en, this message translates to:
  /// **'Add New Exercise'**
  String get addNewExercise;

  /// Share workout tooltip
  ///
  /// In en, this message translates to:
  /// **'Share workout'**
  String get shareWorkout;

  /// Custom weight option
  ///
  /// In en, this message translates to:
  /// **'Custom Weight'**
  String get customWeight;

  /// Weight input hint
  ///
  /// In en, this message translates to:
  /// **'Enter weight value'**
  String get enterWeightValue;

  /// Weight selection title
  ///
  /// In en, this message translates to:
  /// **'Select Weight'**
  String get selectWeight;

  /// Update weight button
  ///
  /// In en, this message translates to:
  /// **'Update Weight'**
  String get updateWeight;

  /// Last weight label
  ///
  /// In en, this message translates to:
  /// **'Last Weight'**
  String get lastWeight;

  /// Delete workout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workout? This action cannot be undone.'**
  String get deleteWorkoutConfirm;

  /// No exercises empty state title
  ///
  /// In en, this message translates to:
  /// **'No Exercises Yet'**
  String get noExercisesYet;

  /// No exercises encouragement
  ///
  /// In en, this message translates to:
  /// **'Your workout is ready for some exercises!'**
  String get workoutReadyForExercises;

  /// Add exercises prompt
  ///
  /// In en, this message translates to:
  /// **'Add exercises to get started with your training'**
  String get addExercisesToStart;

  /// Edit product title
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Add new product title
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProduct;

  /// Product contribution message
  ///
  /// In en, this message translates to:
  /// **'Your contribution will help millions of people make better food choices'**
  String get contributionHelp;

  /// Barcode required field
  ///
  /// In en, this message translates to:
  /// **'Barcode *'**
  String get barcodeRequired;

  /// Barcode input hint
  ///
  /// In en, this message translates to:
  /// **'Enter product barcode'**
  String get enterProductBarcode;

  /// Barcode required validation
  ///
  /// In en, this message translates to:
  /// **'Barcode is required'**
  String get barcodeIsRequired;

  /// Barcode length validation
  ///
  /// In en, this message translates to:
  /// **'Barcode must be at least 8 digits'**
  String get barcodeMinDigits;

  /// Product name required field
  ///
  /// In en, this message translates to:
  /// **'Product Name *'**
  String get productNameRequired;

  /// Product name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// Product name required validation
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get productNameIsRequired;

  /// Brand field
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// Brand input hint
  ///
  /// In en, this message translates to:
  /// **'Enter brand name'**
  String get enterBrandName;

  /// Quantity field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Quantity example
  ///
  /// In en, this message translates to:
  /// **'e.g., 500g, 1L, 250ml'**
  String get quantityExample;

  /// Serving size field
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get servingSize;

  /// Serving size example
  ///
  /// In en, this message translates to:
  /// **'e.g., 30g, 100ml'**
  String get servingSizeExample;

  /// Ingredients field
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Ingredients input hint
  ///
  /// In en, this message translates to:
  /// **'List all ingredients separated by commas'**
  String get ingredientsHint;

  /// Countries field
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countries;

  /// Countries input hint
  ///
  /// In en, this message translates to:
  /// **'Where is this product sold?'**
  String get countriesHint;

  /// Product image field
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// Search hint
  ///
  /// In en, this message translates to:
  /// **'Search by name, brand, or category...'**
  String get searchByNameBrandCategory;

  /// Barcode number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter barcode number'**
  String get enterBarcodeNumber;

  /// Positive feedback message after weight update
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'re getting stronger!'**
  String get weightUpdatePositive;

  /// Negative feedback message after weight update
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, you can do better next time.'**
  String get weightUpdateNegative;

  /// Rate app dialog title
  ///
  /// In en, this message translates to:
  /// **'Enjoying Warrior?'**
  String get enjoyingWarrior;

  /// Rate app dialog message
  ///
  /// In en, this message translates to:
  /// **'Thank you for using Warrior! Would you like to rate the app?'**
  String get rateAppMessage;

  /// Maybe later button
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// Rate the app button
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateTheApp;

  /// Update available dialog title
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// Update available dialog message
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to get the latest features.'**
  String get updateMessage;

  /// Update now button
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Target Every Muscle'**
  String get onboardingTitle1;

  /// Onboarding page 1 description
  ///
  /// In en, this message translates to:
  /// **'Unlock a variety of exercises designed to strengthen and sculpt every muscle group'**
  String get onboardingDesc1;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Customize Your Workouts'**
  String get onboardingTitle2;

  /// Onboarding page 2 description
  ///
  /// In en, this message translates to:
  /// **'Craft your unique workout sets and organize them your way'**
  String get onboardingDesc2;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Your Fitness, Your Way'**
  String get onboardingTitle3;

  /// Onboarding page 3 description
  ///
  /// In en, this message translates to:
  /// **'Take control of your training with personalized workout plans'**
  String get onboardingDesc3;

  /// Basic information section title
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Enter weight hint
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// Height field label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Enter height hint
  ///
  /// In en, this message translates to:
  /// **'Enter height'**
  String get enterHeight;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Enter age hint
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAge;

  /// Gender section title
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Activity level section title
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// Your goal section title
  ///
  /// In en, this message translates to:
  /// **'Your Goal'**
  String get yourGoal;

  /// Weight loss goal option
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weightLoss;

  /// Weight loss goal description
  ///
  /// In en, this message translates to:
  /// **'Lose weight gradually'**
  String get loseWeightGradually;

  /// Maintain weight goal option
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// Maintain weight goal description
  ///
  /// In en, this message translates to:
  /// **'Keep current weight'**
  String get keepCurrentWeight;

  /// Muscle gain goal option
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscleGain;

  /// Muscle gain goal description
  ///
  /// In en, this message translates to:
  /// **'Build muscle mass'**
  String get buildMuscleMass;

  /// Weekly goal section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// Lose action for weekly goal
  ///
  /// In en, this message translates to:
  /// **'Lose'**
  String get lose;

  /// Gain action for weekly goal
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// Kilograms per week unit
  ///
  /// In en, this message translates to:
  /// **'kg per week'**
  String get kgPerWeek;

  /// Calculate button text
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// Calculator header title
  ///
  /// In en, this message translates to:
  /// **'Calculate Your Daily\nCaloric Needs'**
  String get calculateYourDailyCaloricNeeds;

  /// Calculator header subtitle
  ///
  /// In en, this message translates to:
  /// **'Get personalized nutrition targets'**
  String get getPersonalizedNutritionTargets;

  /// Results screen title
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Your results screen title
  ///
  /// In en, this message translates to:
  /// **'Your Results'**
  String get yourResults;

  /// No results message
  ///
  /// In en, this message translates to:
  /// **'No calculation results available'**
  String get noResultsAvailable;

  /// Complete form first instruction
  ///
  /// In en, this message translates to:
  /// **'Please complete the calculator form first'**
  String get completeFormFirst;

  /// Go back button text
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// New calculation tooltip
  ///
  /// In en, this message translates to:
  /// **'New Calculation'**
  String get newCalculation;

  /// Metabolic metrics section title
  ///
  /// In en, this message translates to:
  /// **'Metabolic Metrics'**
  String get metabolicMetrics;

  /// Basal Metabolic Rate abbreviation
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get bmr;

  /// Basal Metabolic Rate full name
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic\nRate'**
  String get basalMetabolicRate;

  /// Total Daily Energy Expenditure abbreviation
  ///
  /// In en, this message translates to:
  /// **'TDEE'**
  String get tdee;

  /// TDEE full name
  ///
  /// In en, this message translates to:
  /// **'Total Daily Energy\nExpenditure'**
  String get totalDailyEnergyExpenditure;

  /// Macronutrient split section title
  ///
  /// In en, this message translates to:
  /// **'Macronutrient Split'**
  String get macronutrientSplit;

  /// Daily macros target section title
  ///
  /// In en, this message translates to:
  /// **'Daily Macros Target'**
  String get dailyMacrosTarget;

  /// Protein nutrient name
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// Carbohydrates nutrient name
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// Fats nutrient name
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// Kilocalories unit
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// Daily calories label
  ///
  /// In en, this message translates to:
  /// **'Daily Calories'**
  String get dailyCalories;

  /// Kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// Grams unit
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

  /// Centimeters unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// Years unit
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Bar unit
  ///
  /// In en, this message translates to:
  /// **'bar'**
  String get bar;

  /// Warning message when creating workout without exercises
  ///
  /// In en, this message translates to:
  /// **'To create your workout set you must select at least one exercise'**
  String get createWorkoutSetWarning;

  /// Don't show again checkbox label
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get dontShowAgain;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button text for updating existing workout set
  ///
  /// In en, this message translates to:
  /// **'Update Your Workout Set'**
  String get updateYourWorkoutSet;

  /// Button text for finishing new workout set
  ///
  /// In en, this message translates to:
  /// **'Finish Your Workout Set'**
  String get finishYourWorkoutSet;

  /// Success message when workout is added
  ///
  /// In en, this message translates to:
  /// **'Workout ({name}) added successfully!'**
  String workoutAddedSuccessfully(String name);

  /// Success message when product is added
  ///
  /// In en, this message translates to:
  /// **'Product added successfully!'**
  String get productAddedSuccessfully;

  /// Success message when product is updated
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get productUpdatedSuccessfully;

  /// Button text to change selected image
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// Button text to take a photo
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Error message when image fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadError;

  /// Tip for taking product photos
  ///
  /// In en, this message translates to:
  /// **'Tip: Take a clear photo of the product front, ingredients list, and nutrition facts.'**
  String get imageTip;

  /// Button text to update product
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// Disclaimer about required fields and database license
  ///
  /// In en, this message translates to:
  /// **'* Required fields\n\nBy submitting, you agree to contribute this information to the Open Food Facts database under the Open Database License.'**
  String get requiredFieldsDisclaimer;

  /// Error message when adding product fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add product. Please try again.'**
  String get failedToAddProduct;

  /// Error message when updating product fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update product. Please try again.'**
  String get failedToUpdateProduct;

  /// Message showing selected image filename
  ///
  /// In en, this message translates to:
  /// **'Image selected: {filename}'**
  String imageSelected(String filename);

  /// Targeted muscles section title
  ///
  /// In en, this message translates to:
  /// **'Targeted Muscles'**
  String get targetedMuscles;

  /// Text shown when downloading exercises
  ///
  /// In en, this message translates to:
  /// **'Downloading exercises'**
  String get downloadingExercises;

  /// Completed status text
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completed;

  /// Downloading status text
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// Success message when download is complete
  ///
  /// In en, this message translates to:
  /// **'Download Complete!'**
  String get downloadComplete;

  /// Message showing number of exercises available offline
  ///
  /// In en, this message translates to:
  /// **'{count} exercises available offline'**
  String exercisesAvailableOffline(int count);

  /// Exercises text (plural)
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercises;

  /// Text shown when workout has no description
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// Delete workout dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteWorkoutTitle(String name);

  /// Delete workout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workout set? This action cannot be undone.'**
  String get deleteWorkoutMessage;

  /// Message when no predefined workouts are cached
  ///
  /// In en, this message translates to:
  /// **'No predefined workouts available offline'**
  String get noPredefinedWorkoutsOffline;

  /// Instruction to go online to download workouts
  ///
  /// In en, this message translates to:
  /// **'Please go online to download it'**
  String get pleaseGoOnlineToDownload;

  /// Offline status message
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get youAreOffline;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Message when offline and no cached workouts
  ///
  /// In en, this message translates to:
  /// **'No cached workouts available. Connect to the internet to download workouts.'**
  String get noCachedWorkoutsAvailable;

  /// Error message when loading predefined workouts fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load predefined workouts'**
  String get failedToLoadPredefinedWorkouts;

  /// Message when no workout groups are available
  ///
  /// In en, this message translates to:
  /// **'No workout groups available'**
  String get noWorkoutGroupsAvailable;

  /// Number of workouts in a group
  ///
  /// In en, this message translates to:
  /// **'{count} workouts'**
  String workoutsCount(int count);

  /// Add To My Workouts Button
  ///
  /// In en, this message translates to:
  /// **'Add to my workouts'**
  String get addToMyWorkouts;

  /// Age input validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get pleaseEnterYourAge;

  /// Number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Age range validation error
  ///
  /// In en, this message translates to:
  /// **'Age must be between 13 and 120 years'**
  String get ageMustBeBetween;

  /// Height input validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get pleaseEnterYourHeight;

  /// Height range validation error
  ///
  /// In en, this message translates to:
  /// **'Height must be between 100 and 250 cm'**
  String get heightMustBeBetween;

  /// Weight input validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get pleaseEnterYourWeight;

  /// Weight range validation error
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 20 and 300 kg'**
  String get weightMustBeBetween;

  /// Weight loss goal plan title
  ///
  /// In en, this message translates to:
  /// **'Weight Loss Plan'**
  String get weightLossPlan;

  /// Muscle gain goal plan title
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain Plan'**
  String get muscleGainPlan;

  /// Maintenance goal plan title
  ///
  /// In en, this message translates to:
  /// **'Maintenance Plan'**
  String get maintenancePlan;

  /// Daily caloric target label
  ///
  /// In en, this message translates to:
  /// **'Daily Caloric Target'**
  String get dailyCaloricTarget;

  /// Per day text
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

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

  /// Barcode scanner instruction
  ///
  /// In en, this message translates to:
  /// **'Position the barcode within the frame'**
  String get positionTheBarcodeWithinTheFrame;

  /// Barcode scanner instruction
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// Unknown product placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProduct;

  /// Allergens section title
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergens;

  /// Labels section title
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labels;

  /// Nutrition facts section title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get nutritionFacts;

  /// Nutrition facts per 100g section title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts (per 100g)'**
  String get nutritionFactsPer100g;

  /// Nutrition scores section title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Scores'**
  String get nutritionScores;

  /// Edit product info tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit Product Info'**
  String get editProductInfo;

  /// Remove from compare button
  ///
  /// In en, this message translates to:
  /// **'Remove from Compare'**
  String get removeFromCompare;

  /// Add to compare button
  ///
  /// In en, this message translates to:
  /// **'Add to Compare'**
  String get addToCompare;

  /// Snackbar message when product is added to comparison
  ///
  /// In en, this message translates to:
  /// **'Product added to comparison successfully'**
  String get productAddedToComparison;

  /// Energy nutrient label
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// Proteins nutrient label
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get proteins;

  /// Carbohydrates nutrient label
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// Sugars nutrient label
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get sugars;

  /// Fat nutrient label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// Saturated fat nutrient label
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get saturatedFat;

  /// Fiber nutrient label
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// Salt nutrient label
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get salt;

  /// No products to compare empty state
  ///
  /// In en, this message translates to:
  /// **'No Products to Compare'**
  String get noProductsToCompare;

  /// Add products to compare instruction
  ///
  /// In en, this message translates to:
  /// **'Add products from search results to compare their nutritional values.'**
  String get addProductsToCompare;

  /// Search products button
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get searchProducts;

  /// Clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Add more products to compare instruction
  ///
  /// In en, this message translates to:
  /// **'Add more products to compare'**
  String get addMoreProductsToCompare;

  /// Nutritional values per 100g title
  ///
  /// In en, this message translates to:
  /// **'Nutritional Values (per 100g)'**
  String get nutritionalValuesPer100g;

  /// Dietary information section title
  ///
  /// In en, this message translates to:
  /// **'Dietary Information'**
  String get dietaryInformation;

  /// No favorites empty state title
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// Add products to favorites instruction
  ///
  /// In en, this message translates to:
  /// **'Add products to your favorites to see them here'**
  String get addProductsToFavorites;

  /// Clear all filters tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearAllFilters;

  /// Show filters button
  ///
  /// In en, this message translates to:
  /// **'Show Filters'**
  String get showFilters;

  /// Hide filters button
  ///
  /// In en, this message translates to:
  /// **'Hide Filters'**
  String get hideFilters;

  /// NOVA group filter label
  ///
  /// In en, this message translates to:
  /// **'NOVA Group'**
  String get novaGroup;

  /// Group label
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// Dietary preferences section title
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get dietaryPreferences;

  /// Exclude allergens section title
  ///
  /// In en, this message translates to:
  /// **'Exclude Allergens'**
  String get excludeAllergens;

  /// Milk allergen
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// Eggs allergen
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get eggs;

  /// Peanuts allergen
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get peanuts;

  /// Tree nuts allergen
  ///
  /// In en, this message translates to:
  /// **'Tree Nuts'**
  String get treeNuts;

  /// Soy allergen
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get soy;

  /// Wheat allergen
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get wheat;

  /// Fish allergen
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// Shellfish allergen
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get shellfish;

  /// No results empty state title
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// No results found message
  ///
  /// In en, this message translates to:
  /// **'No results found.\nTry adjusting your search or filters.'**
  String get noResultsFound;

  /// Product not in database message
  ///
  /// In en, this message translates to:
  /// **'This product is not in our database yet. Would you like to add it to help the community?'**
  String get productNotInDatabase;

  /// Contribution help message
  ///
  /// In en, this message translates to:
  /// **'Your contribution will help millions of users worldwide make better food choices!'**
  String get contributionMessage;

  /// Open Food Facts disclaimer
  ///
  /// In en, this message translates to:
  /// **'* Required fields\n\nBy submitting, you agree to contribute this information to the Open Food Facts database under the Open Database License.'**
  String get openFoodFactsDisclaimer;

  /// Title for OCR scanner screen
  ///
  /// In en, this message translates to:
  /// **'Scan Nutrition Label'**
  String get scanNutritionLabel;

  /// Instruction for OCR scanner
  ///
  /// In en, this message translates to:
  /// **'Position the nutrition label within the frame'**
  String get positionNutritionLabel;

  /// Instruction for OCR scanner with cropping
  ///
  /// In en, this message translates to:
  /// **'Capture & crop the nutrition label'**
  String get captureAndCropInstructions;

  /// Gallery button label
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Manual entry button label
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// OCR failure title
  ///
  /// In en, this message translates to:
  /// **'Scan Failed'**
  String get ocrFailed;

  /// Retake photo button
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// Manual entry button
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// Success message after OCR scan
  ///
  /// In en, this message translates to:
  /// **'Scan Complete!'**
  String get scanComplete;

  /// Per 100 grams unit toggle option
  ///
  /// In en, this message translates to:
  /// **'Per 100g'**
  String get per100g;

  /// Per serving unit toggle option
  ///
  /// In en, this message translates to:
  /// **'Per Serving'**
  String get perServing;

  /// Sodium nutrient label
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// Label for low confidence OCR values
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get lowConfidence;

  /// Helper text for low confidence fields
  ///
  /// In en, this message translates to:
  /// **'Please verify this value'**
  String get pleaseVerify;

  /// Number of nutrition fields detected
  ///
  /// In en, this message translates to:
  /// **'{count} fields'**
  String fieldsDetected(int count);

  /// Label for items waiting to sync
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// Message shown during sync
  ///
  /// In en, this message translates to:
  /// **'Syncing changes...'**
  String get syncingChanges;

  /// Title for pending sync indicator
  ///
  /// In en, this message translates to:
  /// **'Changes pending sync'**
  String get changesPendingSync;

  /// Button to trigger manual sync
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Success message after sync completes
  ///
  /// In en, this message translates to:
  /// **'Synced with server'**
  String get syncedWithServer;

  /// Dialog title for removing item from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// Confirmation message for removing a favorite
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {productName} from your favorites?'**
  String confirmRemoveFavorite(String productName);

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Snackbar message after removing favorite
  ///
  /// In en, this message translates to:
  /// **'{productName} removed from favorites'**
  String removedFromFavorites(String productName);

  /// Undo action button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Sort by label
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Sort by newest date
  ///
  /// In en, this message translates to:
  /// **'Date Added (Newest)'**
  String get dateNewest;

  /// Sort by oldest date
  ///
  /// In en, this message translates to:
  /// **'Date Added (Oldest)'**
  String get dateOldest;

  /// Sort by name ascending
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// Sort by name descending
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// Sort by brand ascending
  ///
  /// In en, this message translates to:
  /// **'Brand (A-Z)'**
  String get brandAZ;

  /// Sort by brand descending
  ///
  /// In en, this message translates to:
  /// **'Brand (Z-A)'**
  String get brandZA;

  /// Message shown when all search results have been loaded
  ///
  /// In en, this message translates to:
  /// **'No more results'**
  String get noMoreResults;

  /// Message shown when product not found, asking user to contribute
  ///
  /// In en, this message translates to:
  /// **'This product is not in our database yet. Would you like to add it to help the community?'**
  String get productNotFoundContribute;

  /// Error message prefix for barcode scanning errors
  ///
  /// In en, this message translates to:
  /// **'Error scanning barcode'**
  String get errorScanningBarcode;

  /// Muscle name: Abs
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get muscleAbs;

  /// Muscle name: Triceps
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// Muscle name: Shoulders
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShoulders;

  /// Muscle name: Legs
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscleLegs;

  /// Muscle name: Chest
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// Muscle name: Biceps
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// Muscle name: Back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleBack;

  /// Muscle name: Forearms
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscleForearms;

  /// Muscle name: Glutes
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGlutes;

  /// Muscle name: Calves
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleCalves;

  /// Muscle name: Core
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// Muscle name: Traps
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get muscleTraps;

  /// Label for exercise count
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Warning message when no exercises are added to workout
  ///
  /// In en, this message translates to:
  /// **'You must add at least one exercise'**
  String get mustAddAtLeastOneExercise;

  /// Tip to organize exercises into sets
  ///
  /// In en, this message translates to:
  /// **'Tip: Organize your exercises into sets for better tracking'**
  String get tipOrganizeExercisesIntoSets;

  /// Add workout details instruction
  ///
  /// In en, this message translates to:
  /// **'Add workout details'**
  String get addWorkoutDetails;

  /// Workout name example
  ///
  /// In en, this message translates to:
  /// **'Example: Chest - Shoulders'**
  String get workoutNameExample;

  /// Workout sets section title
  ///
  /// In en, this message translates to:
  /// **'Workout Sets'**
  String get workoutSets;

  /// Empty state when no workout sets are available
  ///
  /// In en, this message translates to:
  /// **'No sets recorded yet'**
  String get noSetsRecorded;

  /// Repetitions label
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get reps;

  /// Button to add a new set
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// Button to save workout sets
  ///
  /// In en, this message translates to:
  /// **'Save Sets'**
  String get saveSets;

  /// Button to delete a set
  ///
  /// In en, this message translates to:
  /// **'Delete Set'**
  String get deleteSet;

  /// Confirmation message for deleting a set
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this set?'**
  String get confirmDeleteSet;

  /// Message when max sets limit is reached
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 sets allowed'**
  String get maxSetsReached;

  /// Success message when sets are updated
  ///
  /// In en, this message translates to:
  /// **'Sets updated successfully'**
  String get setsUpdated;

  /// Error message when sets update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update sets'**
  String get errorUpdatingSets;

  /// Message when sets are saved in offline mode
  ///
  /// In en, this message translates to:
  /// **'Sets saved locally, will sync when online'**
  String get setsUpdatedOffline;

  /// Message shown when weight increases
  ///
  /// In en, this message translates to:
  /// **'UNSTOPPABLE! You just leveled up! Keep that fire burning! 🔥'**
  String get weightIncreased;

  /// Message shown when weight decreases
  ///
  /// In en, this message translates to:
  /// **'Performance decline. Don\'t let it stop you! You\'ll bounce back! 💪'**
  String get weightDecreased;

  /// Notification message when max weight increases
  ///
  /// In en, this message translates to:
  /// **'Great job! You updated your max weight in this exercise with {weight} kg'**
  String maxWeightUpdateSuccess(String weight);

  /// Tooltip message in grid view explaining that weight update applies to all sets
  ///
  /// In en, this message translates to:
  /// **'This will update the weight for all current sets of this exercise in this workout. To edit individual sets, tap the exercise card.'**
  String get weightSelectionTooltipGridView;

  /// Tooltip message in details screen for weight selection
  ///
  /// In en, this message translates to:
  /// **'Select the weight for this specific set.'**
  String get weightSelectionTooltipDetails;

  /// Tooltip message in details screen for reps selection
  ///
  /// In en, this message translates to:
  /// **'Select the number of repetitions for this set.'**
  String get repsSelectionTooltipDetails;

  /// Title for weight selection bottom sheet in grid view
  ///
  /// In en, this message translates to:
  /// **'Set Weight for All Sets'**
  String get weightSelectionTitleGridView;

  /// Subtitle for weight selection bottom sheet in grid view
  ///
  /// In en, this message translates to:
  /// **'Updates all current sets'**
  String get weightSelectionSubtitleGridView;
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

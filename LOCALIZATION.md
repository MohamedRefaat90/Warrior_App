# Localization Guide for Warrior App

## Overview

The Warrior App uses Flutter's official `l10n` (localization) system with ARB (Application Resource Bundle) files. This guide explains how to use the translation system with the convenient `.tr` extension method.

## Current Setup

### Supported Languages
- English (`en`)
- Arabic (`ar`)

### File Structure
```
lib/
└── core/
    └── localization/
        ├── arb/
        │   ├── en.arb                      # English translations
        │   ├── ar.arb                      # Arabic translations
        │   ├── app_localizations.dart      # Generated base class
        │   ├── app_localizations_en.dart   # Generated English class
        │   └── app_localizations_ar.dart   # Generated Arabic class
        └── translation_extension.dart       # Extension methods for easy usage
```

## How to Use Translations

### Method 1: Using `.tr` Extension (Recommended for Simple Keys)

```dart
import 'package:Warrior/core/localization/translation_extension.dart';

// In your widget
Text('appTitle'.tr(context))
Text('darkMode'.tr(context))
ElevatedButton(
  onPressed: () {},
  child: Text('save'.tr(context)),
)
```

### Method 2: Using `context.l10n` Extension (Best for Autocomplete)

```dart
import 'package:Warrior/core/localization/translation_extension.dart';

// In your widget
Text(context.l10n.appTitle)
Text(context.l10n.darkMode)
ElevatedButton(
  onPressed: () {},
  child: Text(context.l10n.save),
)
```

### Method 3: Traditional AppLocalizations (Still Works)

```dart
import 'package:Warrior/core/localization/arb/app_localizations.dart';

// In your widget
Text(AppLocalizations.of(context)!.appTitle)
```

## Adding New Translations

### Step 1: Add to ARB Files

**English (`lib/core/localization/arb/en.arb`):**
```json
{
  "@@locale": "en",
  "myNewKey": "My New Text",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

**Arabic (`lib/core/localization/arb/ar.arb`):**
```json
{
  "@@locale": "ar",
  "myNewKey": "النص الجديد الخاص بي",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

### Step 2: Regenerate Localization Files

Run this command in the terminal:
```bash
flutter gen-l10n
```

Or simply run:
```bash
flutter pub get
```

The files in `lib/core/localization/arb/` will be automatically regenerated.

### Step 3: Update Translation Extension (for `.tr` support)

Open `lib/core/localization/translation_extension.dart` and add your new case:

```dart
switch (this) {
  // ... existing cases ...
  case 'myNewKey':
    return localizations.myNewKey;
  // ... rest of cases ...
}
```

### Step 4: Use in Your Code

```dart
// Option 1: Using .tr
Text('myNewKey'.tr(context))

// Option 2: Using context.l10n (autocomplete works!)
Text(context.l10n.myNewKey)
```

## Available Translations

### App & Settings
- `appTitle` - Warrior / المحارب
- `darkMode` - Dark Mode / الوضع الداكن
- `language` - Language / اللغة
- `settings` - Settings / الإعدادات
- `english` - English / English
- `arabic` - Arabic / العربية

### Drawer Menu
- `unleashYourPower` - 💪 Unleash Your Power / 💪 أطلق قوتك
- `shareApp` - Share App / مشاركة التطبيق
- `spreadTheWarriorSpirit` - Spread the warrior spirit / انشر روح المحارب
- `rateApp` - Rate App / تقييم التطبيق
- `supportUs` - Support Us ⭐ / ادعمنا ⭐
- `logout` - Logout / تسجيل الخروج
- `takeARest` - Take a rest warrior / خذ قسطاً من الراحة أيها المحارب
- `version` - Version / الإصدار
- `shareAppMessage` - Full share message

### Common Actions
- `cancel` - Cancel / إلغاء
- `delete` - Delete / حذف
- `edit` - Edit / تعديل
- `save` - Save / حفظ
- `create` - Create / إنشاء
- `retry` - Retry / إعادة المحاولة
- `start` - Start / ابدأ

### Screens & Features
- `comingSoon` - Coming Soon / قريباً
- `createWorkoutSet` - Create Workout Set / إنشاء مجموعة تمارين
- `editWorkoutSet` - Edit Workout Set / تعديل مجموعة التمارين
- `searchHistory` - Search History / سجل البحث
- `clearHistory` - Clear History / مسح السجل
- `supplementsScreen` - Supplements / المكملات
- `nutritionScreen` - Nutrition / التغذية

## Changing App Language

The language is managed by the `AppSettingsProvider` in Riverpod:

```dart
// In your widget
final settingsNotifier = ref.read(appSettingsProvider.notifier);

// Set English
await settingsNotifier.setLanguage(const Locale('en'));

// Set Arabic
await settingsNotifier.setLanguage(const Locale('ar'));
```

The language preference is automatically persisted to SharedPreferences.

## Best Practices

### 1. Always Use Translation Keys
❌ **Bad:**
```dart
Text('Settings')  // Hardcoded string
```

✅ **Good:**
```dart
Text('settings'.tr(context))  // Translated
```

### 2. Use Descriptive Keys
❌ **Bad:**
```dart
"text1": "Hello"
"text2": "Goodbye"
```

✅ **Good:**
```dart
"welcomeMessage": "Hello"
"farewellMessage": "Goodbye"
```

### 3. Add Descriptions to ARB Files
```json
{
  "myKey": "My Text",
  "@myKey": {
    "description": "This text appears on the home screen when user logs in"
  }
}
```

### 4. Group Related Translations
```json
{
  "loginTitle": "Login",
  "loginButton": "Sign In",
  "loginForgotPassword": "Forgot Password?",
  "loginNoAccount": "Don't have an account?"
}
```

### 5. Test Both Languages
Always test your UI in both English and Arabic to ensure:
- Text fits properly (Arabic text is typically longer)
- RTL (Right-to-Left) layout works correctly
- No text is hardcoded

## RTL (Right-to-Left) Support

Flutter automatically handles RTL for Arabic. The `appSettings.locale` in `MaterialApp` ensures:
- Layout direction switches automatically
- Text alignment adjusts properly
- Icons and margins flip as needed

No additional code is required for RTL support!

## Translation with Parameters (Future Enhancement)

If you need dynamic values in translations, use ARB placeholders:

**en.arb:**
```json
{
  "welcomeUser": "Welcome, {userName}!",
  "@welcomeUser": {
    "description": "Welcome message with user name",
    "placeholders": {
      "userName": {
        "type": "String"
      }
    }
  }
}
```

**Usage:**
```dart
Text(context.l10n.welcomeUser('Mohamed'))
// Output: "Welcome, Mohamed!"
```

## Troubleshooting

### Translation Not Showing
1. Make sure you ran `flutter gen-l10n` after adding to ARB files
2. Check that the key exists in both `en.arb` and `ar.arb`
3. Verify you added the case in `translation_extension.dart` (for `.tr` method)
4. Restart your app (hot reload might not pick up new localizations)

### "The method 'tr' isn't defined for the type 'String'"
Make sure you imported the extension:
```dart
import 'package:Warrior/core/localization/translation_extension.dart';
```

### Language Not Changing
Check that:
1. `MaterialApp` has `locale: appSettings.locale`
2. `localizationsDelegates` includes `AppLocalizations.delegate`
3. `supportedLocales` includes your target locale

## Quick Reference Commands

```bash
# Regenerate localization files
flutter gen-l10n

# Check for errors
flutter analyze

# Format code
dart format .

# Run app
flutter run
```

## Contributing

When adding new features:
1. Add translation keys to both `en.arb` and `ar.arb`
2. Run `flutter gen-l10n`
3. Update `translation_extension.dart` if using `.tr` method
4. Test in both languages
5. Document any new translation patterns

---

**Note:** This localization system is type-safe, supports hot reload for changes, and provides excellent IDE autocomplete support through the `context.l10n` extension.

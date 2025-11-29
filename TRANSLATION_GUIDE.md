# Translation Migration Guide for Warrior App

## ✅ Completed Translations

I've successfully added and implemented the following translations:

### New Translation Keys Added:

#### Workout Related:

- `updateYourWorkoutSet` - "Update Your Workout Set" / "حدّث مجموعة التمارين بتاعتك"
- `finishYourWorkoutSet` - "Finish Your Workout Set" / "اخلص مجموعة التمارين بتاعتك"
- `workoutAddedSuccessfully` - "Workout ({name}) added successfully!" / "التمرين ({name}) اتضاف بنجاح!"

#### Product Form Related:

- `productAddedSuccessfully` - "Product added successfully!" / "المنتج اتضاف بنجاح!"
- `productUpdatedSuccessfully` - "Product updated successfully!" / "المنتج اتحدّث بنجاح!"
- `changeImage` - "Change Image" / "غيّر الصورة"
- `takePhoto` - "Take Photo" / "صوّر"
- `imageTip` - Photo tip message
- `updateProduct` - "Update Product" / "حدّث المنتج"
- `requiredFieldsDisclaimer` - Disclaimer text
- `failedToAddProduct` - Error message
- `failedToUpdateProduct` - Error message
- `imageSelected` - "Image selected: {filename}" / "الصورة اتاختارت: {filename}"

#### Dialog Related:

- `createWorkoutSetWarning` - Warning message
- `dontShowAgain` - "Don't show this again" / "لا تظهر هذا مرة أخرى"
- `close` - "Close" / "إغلاق"
- `bar` - "bar" / "بار"

### Files Updated:

1. ✅ `lib/core/localization/arb/en.arb` - Added English translations
2. ✅ `lib/core/localization/arb/ar.arb` - Added Arabic translations (Egyptian dialect)
3. ✅ `lib/features/Exercises/presentation/widgets/FinishBTN.dart` - Implemented translations
4. ✅ `lib/features/Exercises/presentation/widgets/workout_alert_dialog.dart` - Implemented translations

## 📋 Remaining Work

### Files That Need Translation Updates:

#### Product Form Screen:

**File**: `lib/features/FoodSearch/presentation/screens/product_form_screen.dart`

Hardcoded strings to replace:

- Line 43: `'Edit Product'` → Use `context.l10n.editProduct` (already exists)
- Line 43: `'Add New Product'` → Use `context.l10n.addNewProduct` (already exists)
- Line 66: `'Your contribution will help millions of users worldwide make better food choices!'` → Use `context.l10n.contributionHelp` (already exists)
- Line 85-98: Form field labels (most already exist in translations)
- Line 210-211: `'Change Image'` / `'Take Photo'` → Use `context.l10n.changeImage` / `context.l10n.takePhoto`
- Line 215: Tip text → Use `context.l10n.imageTip`
- Line 244-245: `'Update Product'` / `'Add Product'` → Use `context.l10n.updateProduct` / `context.l10n.addProduct`
- Line 253: Disclaimer → Use `context.l10n.requiredFieldsDisclaimer`
- Line 362-363: Success messages → Use `context.l10n.productUpdatedSuccessfully` / `context.l10n.productAddedSuccessfully`
- Line 377: Error message → Use `context.l10n.failedToUpdateProduct` / `context.l10n.failedToAddProduct`

## 🎨 Font Family Pattern

When using translations with text widgets, apply the font family pattern:

```dart
import 'package:Warrior/core/settings/app_settings_provider.dart';

// In your widget:
final appSettings = ref.watch(appSettingsProvider.notifier);

Text(
  context.l10n.yourTranslationKey,
  style: TextStyle(
    fontFamily: appSettings.fontFamily(), // This returns 'Cairo' for Arabic, 'Poppins' for English
    // ... other style properties
  ),
)
```

## 🔍 How to Find Remaining Hardcoded Strings

Use these search patterns in your IDE:

1. **Text widgets with hardcoded strings**:

   ```
   Text\s*\(\s*["']
   ```

2. **Common hardcoded patterns**:

   - Search for: `"Update"`, `"Add"`, `"Delete"`, `"Save"`, `"Cancel"`, etc.
   - Search for: `'Update'`, `'Add'`, `'Delete'`, `'Save'`, `'Cancel'`, etc.

3. **Flushbar/Snackbar messages**:
   ```
   Flushbar\(
   ```

## 📝 Adding New Translations

When you find a hardcoded string:

1. **Add to `en.arb`**:

```json
"yourNewKey": "Your English Text",
"@yourNewKey": {
  "description": "Description of where this is used"
}
```

2. **Add to `ar.arb`** (use Egyptian dialect):

```json
"yourNewKey": "النص العربي بتاعك",
"@yourNewKey": {
  "description": "Description of where this is used"
}
```

3. **Run**: `flutter pub get`

4. **Use in code**:

```dart
context.l10n.yourNewKey
```

## 🎯 Priority Files to Check

Based on common patterns, check these files for hardcoded strings:

1. **Workout screens**:

   - `lib/features/Workouts/presentation/screens/*.dart`
   - `lib/features/Workouts/presentation/widgets/*.dart`

2. **Exercise screens**:

   - `lib/features/Exercises/presentation/screens/*.dart`
   - `lib/features/Exercises/presentation/widgets/*.dart`

3. **Food search screens**:

   - `lib/features/FoodSearch/presentation/screens/*.dart`
   - `lib/features/FoodSearch/presentation/widgets/*.dart`

4. **Auth screens**:

   - `lib/features/Auth/presentation/screens/*.dart`
   - `lib/features/Auth/presentation/widgets/*.dart`

5. **Calories calculator**:
   - `lib/features/CaloriesCalculator/presentation/screens/*.dart`
   - `lib/features/CaloriesCalculator/presentation/widgets/*.dart`

## ✨ Egyptian Arabic Translation Tips

When translating to Egyptian Arabic:

- Use colloquial Egyptian dialect (not formal Arabic)
- Examples:
  - "Add" → "ضيف" (not "أضف")
  - "Delete" → "امسح" (not "احذف")
  - "Update" → "حدّث"
  - "Save" → "احفظ"
  - "Cancel" → "إلغاء"
  - "Done" → "تمام"
  - "OK" → "تمام"
  - "Yes" → "أيوه"
  - "No" → "لأ"
  - "Try again" → "جرب تاني"
  - "Success" → "نجح" or "تمام"
  - "Failed" → "فشل"

## 🚀 Next Steps

1. Review `product_form_screen.dart` and update it with the new translations
2. Search for other hardcoded strings in the priority files listed above
3. Add missing translations to both `en.arb` and `ar.arb`
4. Run `flutter pub get` after each batch of translations
5. Test the app in both English and Arabic to ensure proper display
6. Verify that Cairo font is used for Arabic and Poppins for English

## 📌 Notes

- All translations have been added with proper placeholders support where needed
- The `fontFamily()` helper method in `app_settings_provider.dart` automatically returns the correct font based on locale
- Remember to import `translation_ext.dart` to use `context.l10n`
- Always run `flutter pub get` after modifying `.arb` files to regenerate localization classes

import 'package:Warrior/core/localization/arb/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Extension on BuildContext to provide easy access to AppLocalizations
extension LocalizationContext on BuildContext {
  /// Quick access to AppLocalizations
  ///
  /// Usage: context.l10n.appTitle
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

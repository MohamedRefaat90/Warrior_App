class SystemSettings {
  final bool showAds;

  const SystemSettings({required this.showAds});

  // Default when no cache and no network — safe default: Ads OFF.
  factory SystemSettings.defaultSettings() {
    return const SystemSettings(showAds: true);
  }

  /// Parses the flat key/value map returned by GET /auth/systemSettings/.
  ///
  /// Per-key defaults (applied when a key is absent from the response):
  ///   show_ads → true  (maximise revenue unless explicitly disabled)
  ///
  /// Unknown keys are silently ignored, preserving forward-compatibility
  /// when new flags are added without a client update.
  factory SystemSettings.fromMap(Map<String, dynamic> data) {
    return SystemSettings(
      showAds: data['show_ads'] as bool? ?? true,
    );
  }
}

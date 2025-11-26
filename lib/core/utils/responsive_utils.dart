import 'package:flutter/material.dart';

/// Utility class for responsive design
/// Provides breakpoint detection and adaptive helpers
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Max widths for content
  static const double maxContentWidth = 1200;
  static const double maxCardWidth = 400;

  /// Returns responsive avatar size
  static double avatarSize(BuildContext context,
      {double mobile = 40, double tablet = 48, double desktop = 56}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns responsive badge/chip size
  static double badgeSize(BuildContext context) {
    if (isDesktop(context)) return 56.0;
    if (isTablet(context)) return 52.0;
    return 48.0;
  }

  /// Returns responsive border radius
  static double borderRadius(BuildContext context,
      {double mobile = 12, double tablet = 14, double desktop = 16}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns responsive bottom sheet height factor
  static double bottomSheetHeightFactor(BuildContext context) {
    if (isDesktop(context)) return 0.5;
    if (isTablet(context)) return 0.6;
    return 0.7;
  }

  /// Returns responsive button padding
  static EdgeInsets buttonPadding(BuildContext context) {
    if (isDesktop(context))
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    if (isTablet(context))
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
  }

  /// Returns the aspect ratio for cards based on screen size
  static double cardAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 1.4;
    if (isTablet(context)) return 1.3;
    return 1.2;
  }

  /// Returns responsive card padding
  static EdgeInsets cardPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.all(24.0);
    if (isTablet(context)) return const EdgeInsets.all(20.0);
    return const EdgeInsets.all(16.0);
  }

  /// Returns responsive dialog width
  static double dialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return 500;
    if (isTablet(context)) return screenWidth * 0.7;
    return screenWidth * 0.9;
  }

  /// Returns responsive extra large spacing (32-56px range)
  static double extraLargeSpacing(BuildContext context) {
    if (isDesktop(context)) return 56.0;
    if (isTablet(context)) return 44.0;
    return 32.0;
  }

  /// Returns responsive font size scale factor
  static double fontScale(BuildContext context) {
    if (isDesktop(context)) return 1.15;
    if (isTablet(context)) return 1.08;
    return 1.0;
  }

  /// Returns the number of columns for a grid based on screen size
  static int getGridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns responsive symmetric horizontal padding
  static EdgeInsets horizontalEdgePadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: horizontalPadding(context));
  }

  /// Returns responsive horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  /// Returns responsive icon size based on screen size
  static double iconSize(BuildContext context,
      {double mobile = 24, double tablet = 28, double desktop = 32}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns responsive image size based on screen
  static double imageSize(BuildContext context,
      {double mobile = 120, double tablet = 150, double desktop = 180}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns true if the screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Returns true if the screen is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Returns true if the screen is tablet size
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  /// Returns responsive large icon size (for hero icons, etc.)
  static double largeIconSize(BuildContext context) {
    if (isDesktop(context)) return 80.0;
    if (isTablet(context)) return 72.0;
    return 64.0;
  }

  /// Returns responsive large spacing (24-40px range)
  static double largeSpacing(BuildContext context) {
    if (isDesktop(context)) return 40.0;
    if (isTablet(context)) return 32.0;
    return 24.0;
  }

  /// Returns responsive list tile height
  static double listTileHeight(BuildContext context) {
    if (isDesktop(context)) return 80.0;
    if (isTablet(context)) return 72.0;
    return 64.0;
  }

  /// Returns responsive medium spacing (16-24px range)
  static double mediumSpacing(BuildContext context) {
    if (isDesktop(context)) return 24.0;
    if (isTablet(context)) return 20.0;
    return 16.0;
  }

  /// Returns responsive screen padding
  static EdgeInsets screenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: verticalPadding(context),
    );
  }

  /// Returns responsive small spacing (8-12px range)
  static double smallSpacing(BuildContext context) {
    if (isDesktop(context)) return 12.0;
    if (isTablet(context)) return 10.0;
    return 8.0;
  }

  /// Returns responsive spacing based on screen size
  static double spacing(BuildContext context,
      {double mobile = 16, double tablet = 20, double desktop = 24}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns a responsive value based on screen size
  static T value<T>(BuildContext context,
      {required T mobile, T? tablet, required T desktop}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Returns responsive vertical padding based on screen size
  static double verticalPadding(BuildContext context) {
    if (isDesktop(context)) return 24.0;
    if (isTablet(context)) return 20.0;
    return 16.0;
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get responsive card padding
  EdgeInsets get cardPadding => ResponsiveUtils.cardPadding(this);

  /// Get responsive extra large spacing
  double get extraLargeSpacing => ResponsiveUtils.extraLargeSpacing(this);

  /// Get font scale factor
  double get fontScale => ResponsiveUtils.fontScale(this);

  /// Get responsive horizontal padding
  double get horizontalPadding => ResponsiveUtils.horizontalPadding(this);

  /// Check if desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Get responsive large icon size
  double get largeIconSize => ResponsiveUtils.largeIconSize(this);

  /// Get responsive large spacing
  double get largeSpacing => ResponsiveUtils.largeSpacing(this);

  /// Get responsive medium spacing
  double get mediumSpacing => ResponsiveUtils.mediumSpacing(this);

  /// Get responsive border radius
  double get responsiveBorderRadius => ResponsiveUtils.borderRadius(this);

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get responsive screen padding
  EdgeInsets get screenPadding => ResponsiveUtils.screenPadding(this);

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get responsive small spacing
  double get smallSpacing => ResponsiveUtils.smallSpacing(this);

  /// Get responsive vertical padding
  double get verticalPadding => ResponsiveUtils.verticalPadding(this);
}

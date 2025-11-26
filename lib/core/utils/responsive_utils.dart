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

  /// Returns responsive horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
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

  /// Returns responsive vertical padding based on screen size
  static double verticalPadding(BuildContext context) {
    if (isDesktop(context)) return 24.0;
    if (isTablet(context)) return 20.0;
    return 16.0;
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  /// Check if desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
}

import 'package:flutter/material.dart';

/// Application color constants
/// Note: For theme-aware colors, prefer using Theme.of(context).colorScheme
/// These are kept for backward compatibility and specific use cases
abstract class AppColors {
  // Basic colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Light theme colors
  static Color primaryColor = const Color(0xFFB71C1C);
  static Color red = const Color.fromARGB(255, 120, 22, 15);
  static Color green = Colors.green;

  // Dark theme specific colors (Purple-Navy Mix)
  static const Color darkBackground = Color(0xFF0F0E1E); // Deep purple-navy
  static const Color darkSurface = Color(0xFF1A1B2E); // Lighter purple-navy
  static const Color darkSurfaceVariant =
      Color(0xFF252538); // Even lighter purple-navy
  static const Color darkPrimary = Color(0xFF333BC4); // Vibrant red
  static const Color darkSecondary =
      Color.fromARGB(255, 98, 50, 230); // Purple accent
  static const Color darkOnSurface =
      Color(0xFFE8E4F3); // Light purple-tinted white
  static const Color darkOnSurfaceVariant = Color(0xFF9694A3); // gray
}

import 'package:flutter/material.dart';

/// Application color constants
/// Note: For theme-aware colors, prefer using Theme.of(context).colorScheme
/// These are kept for backward compatibility and specific use cases
abstract class AppColors {
  // Basic colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Light theme colors
  static Color? primaryColor = const Color(0xFFB71C1C);
  static Color? red = const Color.fromARGB(255, 120, 22, 15);
  static Color? green = Colors.green;

  // Dark theme specific colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkPrimary = Color(0xFFFF5252);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);
}

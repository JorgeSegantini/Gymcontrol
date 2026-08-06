import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'gc_colors.dart';

abstract final class GcLightTheme {
  static ThemeData build() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GcColors.lightPrimary,
      brightness: Brightness.light,
      primary: GcColors.lightPrimary,
      secondary: GcColors.lightSecondary,
      error: GcColors.error,
      surface: GcColors.lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GcColors.lightBackground,
      cardColor: GcColors.lightSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: GcColors.lightPrimary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: GcColors.lightSurface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GcColors.lightSecondary,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GcColors.lightSecondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: GcColors.lightSurface,
        border: OutlineInputBorder(borderRadius: AppRadius.md),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GcColors.lightPrimary,
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
    );
  }
}

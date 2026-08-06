import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'gc_colors.dart';

abstract final class GcDarkTheme {
  static ThemeData build() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GcColors.darkPrimary,
      brightness: Brightness.dark,
      primary: GcColors.darkPrimary,
      secondary: GcColors.darkSecondary,
      error: GcColors.errorDark,
      surface: GcColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GcColors.darkBackground,
      cardColor: GcColors.darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: GcColors.darkSurface,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: GcColors.darkCard,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GcColors.darkSecondary,
        foregroundColor: Colors.black,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GcColors.darkSecondary,
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: GcColors.darkSurface,
        border: OutlineInputBorder(borderRadius: AppRadius.md),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GcColors.darkPrimary,
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
    );
  }
}

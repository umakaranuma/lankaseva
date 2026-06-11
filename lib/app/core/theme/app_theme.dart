import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// ---------------------------------------------------------------------------
/// AppTheme
/// ---------------------------------------------------------------------------
/// Builds the Material [ThemeData] for both light and dark mode from the
/// design tokens in [AppColors]. Only framework-level styling lives here
/// (app bars, inputs, buttons); screen-level styling reads tokens directly.
/// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._(); // Static factory holder — never instantiated.

  /// Light theme — built from the [AppColors.light] palette.
  static ThemeData get light => _build(AppColors.light, Brightness.light);

  /// Dark theme — built from the [AppColors.dark] palette.
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  /// Shared builder so light/dark stay structurally identical and only the
  /// palette swaps (spec 2.2: "All tokens are prefixed identically").
  static ThemeData _build(AppColors c, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.bgScreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: brightness,
        primary: c.primary,
        surface: c.bgCard,
        error: c.emergency,
      ),
      // Sinhala / Tamil glyphs fall back to platform Noto fonts automatically;
      // system font keeps script rendering correct (spec 2.3).
      fontFamily: null,
      appBarTheme: AppBarTheme(
        backgroundColor: c.primary,
        foregroundColor: c.primaryText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: c.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          side: BorderSide(color: c.borderLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.primaryText,
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget + 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bgInput,
        hintStyle: TextStyle(color: c.textTertiary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space4, vertical: AppDimens.space3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: c.borderMedium),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.bgCard,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      dividerColor: c.borderLight,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: TextStyle(color: c.bgCard, fontSize: 13),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

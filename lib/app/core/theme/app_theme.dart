import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// ---------------------------------------------------------------------------
/// AppTheme
/// ---------------------------------------------------------------------------
/// Builds the Material [ThemeData] for both light and dark mode from the
/// design tokens in [AppColors]. Only framework-level styling lives here
/// (app bars, inputs, buttons); screen-level styling reads tokens directly.
///
/// v2 "rich" refresh: softer rounded shapes, tinted elevation on cards /
/// bottom-nav / dialogs, a gold secondary accent, and a warmer type colour.
/// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.bgScreen,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: base.copyWith(
        primary: c.primary,
        onPrimary: c.primaryText,
        primaryContainer: c.primaryLight,
        onPrimaryContainer: c.primaryDark,
        secondary: c.secondary,
        onSecondary: c.secondaryText,
        secondaryContainer: c.secondaryLight,
        surface: c.bgCard,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.bgSecondary,
        error: c.emergency,
        outline: c.borderMedium,
        outlineVariant: c.borderLight,
      ),
      fontFamily: null,
      appBarTheme: AppBarTheme(
        // Deepest brand green in BOTH themes (screens paint a gradient over
        // this); content is [onEmphasis] so it reads on the dark fill.
        backgroundColor: c.primaryDark,
        foregroundColor: c.onEmphasis,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: c.onEmphasis,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: c.onEmphasis),
        actionsIconTheme: IconThemeData(color: c.onEmphasis),
      ),
      cardTheme: CardThemeData(
        color: c.bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.primaryText,
          disabledBackgroundColor: c.bgSecondary,
          disabledForegroundColor: c.textDisabled,
          elevation: 2,
          shadowColor: c.primary.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget + 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.primaryText,
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget + 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size.fromHeight(AppDimens.minTouchTarget + 4),
          side: BorderSide(color: c.primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.bgSecondary,
        side: BorderSide.none,
        labelStyle: TextStyle(color: c.textSecondary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.bgInput,
        hintStyle: TextStyle(color: c.textTertiary, fontSize: 14),
        prefixIconColor: c.textTertiary,
        suffixIconColor: c.textTertiary,
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
          borderSide: BorderSide(color: c.primary, width: 1.6),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.bgCard,
        elevation: 12,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textTertiary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.bgCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bgCard,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXxl)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.borderLight, space: 1),
      dividerColor: c.borderLight,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary,
        contentTextStyle: TextStyle(color: c.bgCard, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// AppColors
/// ---------------------------------------------------------------------------
/// Central colour token definitions for LankaSeva, mirroring the design
/// system in `docs/LankaSeva_Product_Spec.md` (sections 2.1 / 2.2).
///
/// Two immutable palettes are exposed (`AppColors.light` / `AppColors.dark`)
/// and the active palette is resolved with `AppColors.of(context)` based on
/// the current [ThemeData.brightness]. UI code must NEVER hardcode hex
/// values — always read tokens from this class.
/// ---------------------------------------------------------------------------
class AppColors {
  // ---- Primary brand ----
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryText;

  // ---- Neutral surfaces ----
  final Color bgScreen;
  final Color bgCard;
  final Color bgInput;
  final Color bgSecondary;

  // ---- Text ----
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  // ---- Semantic ----
  final Color emergency;
  final Color emergencyLight;
  final Color success;
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color info;
  final Color infoLight;
  final Color star;
  final Color starLight;

  // ---- Borders ----
  final Color borderLight;
  final Color borderMedium;
  final Color borderStrong;

  const AppColors._({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryText,
    required this.bgScreen,
    required this.bgCard,
    required this.bgInput,
    required this.bgSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.emergency,
    required this.emergencyLight,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.info,
    required this.infoLight,
    required this.star,
    required this.starLight,
    required this.borderLight,
    required this.borderMedium,
    required this.borderStrong,
  });

  /// Light mode palette — spec section 2.1.
  static const AppColors light = AppColors._(
    primary: Color(0xFF0F6E56),
    primaryLight: Color(0xFFE1F5EE),
    primaryDark: Color(0xFF085041),
    primaryText: Color(0xFFFFFFFF),
    bgScreen: Color(0xFFF4F4F2),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFF8F8F7),
    bgSecondary: Color(0xFFEFEFED),
    textPrimary: Color(0xFF1A1A18),
    textSecondary: Color(0xFF5C5C59),
    textTertiary: Color(0xFF9C9C98),
    textDisabled: Color(0xFFC4C4C0),
    emergency: Color(0xFFA32D2D),
    emergencyLight: Color(0xFFFCEBEB),
    success: Color(0xFF3B6D11),
    successLight: Color(0xFFEAF3DE),
    warning: Color(0xFF854F0B),
    warningLight: Color(0xFFFAEEDA),
    info: Color(0xFF185FA5),
    infoLight: Color(0xFFE6F1FB),
    star: Color(0xFFBA7517),
    starLight: Color(0xFFFAEEDA),
    borderLight: Color(0x14000000), // rgba(0,0,0,0.08)
    borderMedium: Color(0x26000000), // rgba(0,0,0,0.15)
    borderStrong: Color(0x40000000), // rgba(0,0,0,0.25)
  );

  /// Dark mode palette — spec section 2.2.
  static const AppColors dark = AppColors._(
    primary: Color(0xFF1D9E75),
    primaryLight: Color(0xFF04342C),
    primaryDark: Color(0xFF085041),
    primaryText: Color(0xFFFFFFFF),
    bgScreen: Color(0xFF111110),
    bgCard: Color(0xFF1E1E1C),
    bgInput: Color(0xFF252523),
    bgSecondary: Color(0xFF2C2C2A),
    textPrimary: Color(0xFFF0F0EE),
    textSecondary: Color(0xFFABABAB),
    textTertiary: Color(0xFF6E6E6A),
    textDisabled: Color(0xFF4A4A47),
    emergency: Color(0xFFE24B4A),
    emergencyLight: Color(0xFF501313),
    success: Color(0xFF97C459),
    successLight: Color(0xFF173404),
    warning: Color(0xFFEF9F27),
    warningLight: Color(0xFF412402),
    info: Color(0xFF85B7EB),
    infoLight: Color(0xFF042C53),
    star: Color(0xFFFAC775),
    starLight: Color(0xFF412402),
    borderLight: Color(0x14FFFFFF),
    borderMedium: Color(0x26FFFFFF),
    borderStrong: Color(0x40FFFFFF),
  );

  /// Resolves the active palette from the ambient [Theme] brightness so
  /// every widget automatically follows light / dark mode switches.
  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

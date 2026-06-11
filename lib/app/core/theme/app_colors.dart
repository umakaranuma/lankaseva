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

  /// Light mode palette — refreshed from the spec baseline for a warmer,
  /// more inviting feel: a vivid emerald primary (trust + Sri Lankan
  /// identity), soft mint surfaces, golden star accents and friendlier
  /// semantic tones, all WCAG AA on their backgrounds.
  static const AppColors light = AppColors._(
    primary: Color(0xFF00866E),
    primaryLight: Color(0xFFDCF3EC),
    primaryDark: Color(0xFF00604F),
    primaryText: Color(0xFFFFFFFF),
    bgScreen: Color(0xFFF4F8F6),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFF0F5F3),
    bgSecondary: Color(0xFFE8EFEC),
    textPrimary: Color(0xFF15201C),
    textSecondary: Color(0xFF54615C),
    textTertiary: Color(0xFF8B9893),
    textDisabled: Color(0xFFC2CCC8),
    emergency: Color(0xFFC53A3A),
    emergencyLight: Color(0xFFFCEDED),
    success: Color(0xFF2E7D32),
    successLight: Color(0xFFE7F3E7),
    warning: Color(0xFFB26205),
    warningLight: Color(0xFFFBF0DE),
    info: Color(0xFF1A6FC4),
    infoLight: Color(0xFFE7F1FB),
    star: Color(0xFFD98E04),
    starLight: Color(0xFFFBF0DE),
    borderLight: Color(0x14000000), // rgba(0,0,0,0.08)
    borderMedium: Color(0x26000000), // rgba(0,0,0,0.15)
    borderStrong: Color(0x40000000), // rgba(0,0,0,0.25)
  );

  /// Dark mode palette — same refreshed hues lifted for contrast on the
  /// deep green-tinted dark surfaces (not flat black: feels warmer).
  static const AppColors dark = AppColors._(
    primary: Color(0xFF2EC79E),
    primaryLight: Color(0xFF0B3B30),
    primaryDark: Color(0xFF00604F),
    primaryText: Color(0xFF06281F),
    bgScreen: Color(0xFF0E1513),
    bgCard: Color(0xFF1A2320),
    bgInput: Color(0xFF222C29),
    bgSecondary: Color(0xFF293431),
    textPrimary: Color(0xFFECF2EF),
    textSecondary: Color(0xFFA9B5B0),
    textTertiary: Color(0xFF6F7C77),
    textDisabled: Color(0xFF49544F),
    emergency: Color(0xFFEF6B6A),
    emergencyLight: Color(0xFF491616),
    success: Color(0xFF8FCB6B),
    successLight: Color(0xFF1B3312),
    warning: Color(0xFFF3A93C),
    warningLight: Color(0xFF3E2706),
    info: Color(0xFF7FB7F0),
    infoLight: Color(0xFF0A2D50),
    star: Color(0xFFF5C462),
    starLight: Color(0xFF3E2706),
    borderLight: Color(0x14FFFFFF),
    borderMedium: Color(0x26FFFFFF),
    borderStrong: Color(0x40FFFFFF),
  );

  /// Resolves the active palette from the ambient [Theme] brightness so
  /// every widget automatically follows light / dark mode switches.
  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

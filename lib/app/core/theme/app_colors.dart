import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// AppColors — the SINGLE source of truth for every colour in LankaSeva.
///
/// Screens and widgets must never write a `Color(0x…)` literal or a raw
/// `Colors.*` swatch. They read a token from here via `AppColors.of(context)`,
/// which returns the light or dark palette for the current theme.
///
/// v4 palette — a calm, near-monochrome **green family** taken from the logo.
/// Visual hierarchy comes from shade + elevation + type weight, not from many
/// hues. Reserved non-greens:
///   • [emergency] red  — fire / SOS / destructive only
///   • [verified] gold  — optional "featured / verified office" badge only
///   • [star] gold      — rating glyphs
/// ---------------------------------------------------------------------------
class AppColors {
  // ---- Primary brand (green) ----
  final Color primary; // #0D6552  logo-exact brand, active nav, buttons
  final Color primaryLight; // pale wash — chips, icon wells, selected rows, badges
  final Color primaryDark; // #0A4536  app bar / header gradient end (darkest)
  final Color primaryText; // content ON a solid [primary] fill

  // ---- Secondary (Primary Mid — a lighter green, NOT a new hue) ----
  final Color secondary; // #1E8A6B  links, secondary buttons
  final Color secondaryLight;
  final Color secondaryDark;
  final Color secondaryText;

  // ---- Neutral surfaces ----
  final Color bgScreen; // #EDF7F3  scaffold / section background tint
  final Color bgCard; // #FFFFFF  cards, main content
  final Color bgInput; // field fills
  final Color bgSecondary; // chips, muted fills

  // ---- Text ----
  final Color textPrimary; // #0E231C
  final Color textSecondary; // #4A6B60
  final Color textTertiary; // #96AEA4
  final Color textDisabled;

  // ---- Semantic ----
  final Color emergency; // #C62828  reserved: fire / SOS / destructive
  final Color emergencyLight;
  final Color success; // "open" state, positive confirmations
  final Color successLight;
  final Color warning;
  final Color warningLight;
  final Color info;
  final Color infoLight;
  final Color star; // #C6871F  rating glyph only
  final Color starLight;
  final Color verified; // #C6871F  optional featured / verified badge only
  final Color verifiedLight;

  // ---- Borders ----
  final Color borderLight; // #D3E6DE  dividers, card outlines
  final Color borderMedium;
  final Color borderStrong;

  // ---- Fixed-contrast helpers (content that sits on a coloured fill) ----
  final Color onEmphasis; // text / icons on a gradient header or accent tile
  final Color scrim; // darkening overlay for gradients & image scrims

  // ---- Depth ----
  final Color _shadow;
  final List<Color> _headerGradient;
  final List<Color> _accentGradient;

  const AppColors._({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryText,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.secondaryText,
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
    required this.verified,
    required this.verifiedLight,
    required this.borderLight,
    required this.borderMedium,
    required this.borderStrong,
    required this.onEmphasis,
    required this.scrim,
    required Color shadow,
    required List<Color> headerGradient,
    required List<Color> accentGradient,
  })  : _shadow = shadow,
        _headerGradient = headerGradient,
        _accentGradient = accentGradient;

  // ---- Derived helpers -------------------------------------------------

  LinearGradient get headerGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _headerGradient,
      );

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _accentGradient,
      );

  List<BoxShadow> get shadowSm => [
        BoxShadow(color: _shadow, blurRadius: 8, offset: const Offset(0, 2)),
      ];

  List<BoxShadow> get shadowMd => [
        BoxShadow(color: _shadow, blurRadius: 18, offset: const Offset(0, 8)),
      ];

  List<BoxShadow> get shadowLg => [
        BoxShadow(color: _shadow, blurRadius: 30, offset: const Offset(0, 14)),
      ];

  // ---- Light --------------------------------------------------------

  static const AppColors light = AppColors._(
    primary: Color(0xFF0D6552),
    primaryLight: Color(0xFFDDEFE8),
    primaryDark: Color(0xFF0A4536),
    primaryText: Color(0xFFFFFFFF),
    secondary: Color(0xFF1E8A6B),
    secondaryLight: Color(0xFFDDEFE8),
    secondaryDark: Color(0xFF0D6552),
    secondaryText: Color(0xFFFFFFFF),
    bgScreen: Color(0xFFEDF7F3),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFEAF4EF),
    bgSecondary: Color(0xFFDEEFE7),
    textPrimary: Color(0xFF0E231C),
    textSecondary: Color(0xFF4A6B60),
    textTertiary: Color(0xFF7E978C),
    textDisabled: Color(0xFF96AEA4),
    emergency: Color(0xFFC62828),
    emergencyLight: Color(0xFFFBEAEA),
    success: Color(0xFF1E8A6B),
    successLight: Color(0xFFDDEFE8),
    warning: Color(0xFFC6871F),
    warningLight: Color(0xFFF8EEDD),
    info: Color(0xFF1E8A6B),
    infoLight: Color(0xFFDDEFE8),
    star: Color(0xFFC6871F),
    starLight: Color(0xFFF8EEDD),
    verified: Color(0xFFC6871F),
    verifiedLight: Color(0xFFF8EEDD),
    borderLight: Color(0xFFD3E6DE),
    borderMedium: Color(0xFFBAD4C9),
    borderStrong: Color(0xFF9DC0B2),
    onEmphasis: Color(0xFFFFFFFF),
    scrim: Color(0xFF000000),
    shadow: Color(0x1A0A4536),
    headerGradient: [Color(0xFF0D6552), Color(0xFF0A4536)],
    accentGradient: [Color(0xFFD24A44), Color(0xFF9E2020)],
  );

  // ---- Dark --------------------------------------------------------

  static const AppColors dark = AppColors._(
    // A confident, saturated emerald that keeps the brand hue instead of the
    // pale mint tint — reads as "professional" on the near-black surfaces
    // while still clearing the 3:1 contrast bar for icons / controls.
    primary: Color(0xFF2E9E7C),
    primaryLight: Color(0xFF10362C),
    primaryDark: Color(0xFF0A4536),
    primaryText: Color(0xFF04231B),
    secondary: Color(0xFF54BE9C),
    secondaryLight: Color(0xFF10362C),
    secondaryDark: Color(0xFFBEE3D3),
    secondaryText: Color(0xFF04231B),
    bgScreen: Color(0xFF0B1512),
    bgCard: Color(0xFF12211C),
    bgInput: Color(0xFF182A24),
    bgSecondary: Color(0xFF1E332C),
    textPrimary: Color(0xFFE8F1ED),
    textSecondary: Color(0xFFA6BCB3),
    textTertiary: Color(0xFF6E837A),
    textDisabled: Color(0xFF47574F),
    emergency: Color(0xFFEF5B57),
    emergencyLight: Color(0xFF3A1512),
    success: Color(0xFF5CB79A),
    successLight: Color(0xFF123C31),
    warning: Color(0xFFDBA94A),
    warningLight: Color(0xFF3A2C10),
    info: Color(0xFF5CB79A),
    infoLight: Color(0xFF123C31),
    star: Color(0xFFDBA94A),
    starLight: Color(0xFF3A2C10),
    verified: Color(0xFFDBA94A),
    verifiedLight: Color(0xFF3A2C10),
    borderLight: Color(0xFF243830),
    borderMedium: Color(0xFF324A40),
    borderStrong: Color(0xFF456156),
    onEmphasis: Color(0xFFF3F8F6),
    scrim: Color(0xFF000000),
    shadow: Color(0x59000000),
    headerGradient: [Color(0xFF0C5544), Color(0xFF073228)],
    accentGradient: [Color(0xFFB23A38), Color(0xFF7C1F1E)],
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

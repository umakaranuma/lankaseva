/// ---------------------------------------------------------------------------
/// AppDimens
/// ---------------------------------------------------------------------------
/// Spacing scale and border-radius tokens from the design system
/// (spec section 2.4). Use these constants instead of magic numbers so the
/// rhythm of the layout stays consistent across every screen.
/// ---------------------------------------------------------------------------
class AppDimens {
  AppDimens._(); // Static token holder — never instantiated.

  // ---- Spacing scale ----
  static const double space1 = 4; // Icon gap, tight inline
  static const double space2 = 8; // Grid gaps, badge padding
  static const double space3 = 12; // Card internal padding
  static const double space4 = 16; // Screen horizontal padding
  static const double space5 = 20; // Section vertical gap
  static const double space6 = 24; // Large section gap

  // ---- Border radius ----
  static const double radiusSm = 8; // Badges, chips
  static const double radiusMd = 12; // Buttons, inputs, small cards
  static const double radiusLg = 16; // Service cards, modals
  static const double radiusXl = 22; // Bottom sheets, hero cards
  static const double radiusXxl = 28; // Pull-up sheets
  static const double radiusFull = 999; // Avatars, language pills

  /// Minimum accessible touch target (spec 5.10 — 44×44pt).
  static const double minTouchTarget = 44;
}

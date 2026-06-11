import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// AppTextStyles
/// ---------------------------------------------------------------------------
/// Type scale from the design system (spec section 2.3). Styles are colour-
/// agnostic — callers apply token colours via `copyWith(color: ...)` so the
/// same scale works in light and dark mode.
/// ---------------------------------------------------------------------------
class AppTextStyles {
  AppTextStyles._(); // Static token holder — never instantiated.

  /// 24px / 600 — screen titles.
  static const TextStyle display =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.2);

  /// 20px / 600 — section headings.
  static const TextStyle heading1 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);

  /// 17px / 600 — card titles.
  static const TextStyle heading2 =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.4);

  /// 15px / 500 — sub-headings, service names.
  static const TextStyle heading3 =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4);

  /// 14px / 400 — body text, descriptions.
  static const TextStyle body =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);

  /// 13px / 400 — secondary body, addresses.
  static const TextStyle bodySm =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);

  /// 12px / 400 — reviews, timestamps.
  static const TextStyle caption =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);

  /// 11px / 500 — badges, uppercase section labels.
  static const TextStyle label =
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2);

  /// 10px / 400 — category grid labels.
  static const TextStyle micro =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w400, height: 1.2);

  /// Section label rule: uppercase + 0.07em letter spacing (spec 2.3).
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.77, // 0.07em of 11px
  );

  /// Phone number rule: tabular figures + medium weight (spec 2.3).
  static const TextStyle phoneNumber = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Emergency number rule: 24px bold white on coloured tile (spec 2.3).
  static const TextStyle emergencyNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

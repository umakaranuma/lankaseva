import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/config/api_config.dart';
import 'api_client.dart';

/// ---------------------------------------------------------------------------
/// EmergencyDataSource
/// ---------------------------------------------------------------------------
/// Holds the national emergency hotlines shown on the Emergency hub and the
/// home quick-dial row. There is NO bundled data: both lists are empty until
/// [load] fills them from `GET /api/emergency/`.
///
/// The translated display name stays an i18n key (resolved with `.tr`) and
/// the icon is mapped from the backend's `icon_key` to a Flutter icon here —
/// everything else (numbers, colours, ordering, quick-dial membership) is
/// owned by the database.
/// ---------------------------------------------------------------------------
class EmergencyDataSource {
  EmergencyDataSource._();

  /// All hub hotlines (Emergency screen), loaded from the API.
  static List<EmergencyContact> hotlines = <EmergencyContact>[];

  /// The home-screen quick-dial tiles, loaded from the API.
  static List<EmergencyContact> quickDial = <EmergencyContact>[];

  /// Maps the backend's `icon_key` strings onto Material icons.
  static const Map<String, IconData> _icons = {
    'shield': Icons.shield_outlined,
    'medical': Icons.medical_services_outlined,
    'fire': Icons.local_fire_department_outlined,
    'warning': Icons.warning_amber_outlined,
    'family': Icons.family_restroom_outlined,
    'mental': Icons.psychology_outlined,
    'bolt': Icons.bolt_outlined,
    'water': Icons.water_drop_outlined,
    'travel': Icons.travel_explore_outlined,
    'gavel': Icons.gavel_outlined,
  };

  static Color _parseColor(String hex) {
    final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(0xFF000000 | value);
  }

  static EmergencyContact _fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        nameKey: json['name_key'],
        number: json['number'],
        icon: _icons[json['icon_key']] ?? Icons.call_outlined,
        color: _parseColor(json['color']),
      );

  /// Loads both lists from `GET /api/emergency/`. Throws on failure so the
  /// bootstrap can show an error/retry state (no offline fallback).
  static Future<void> load() async {
    final rows =
        (await ApiClient.get(ApiConfig.emergency) as List).cast<Map<String, dynamic>>();
    hotlines = [
      for (final r in rows)
        if (r['is_quick_dial'] != true) _fromJson(r)
    ];
    quickDial = [
      for (final r in rows)
        if (r['is_quick_dial'] == true) _fromJson(r)
    ];
  }
}

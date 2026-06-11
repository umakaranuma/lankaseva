import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// App-wide static constants: categories, districts, emergency hotlines.
/// This is pure reference data from the product spec — it never changes at
/// runtime, so it lives here instead of inside a controller.
/// ---------------------------------------------------------------------------

/// Service category identifiers (spec section 7 — Category Enum).
enum ServiceCategory {
  electricity,
  water,
  hospital,
  police,
  court,
  school,
  government,
  transport,
  post,
}

/// Visual + label metadata for a service category (icon, colour, names in
/// all three languages). Looked up via [kCategories].
class CategoryMeta {
  final ServiceCategory id;
  final IconData icon;
  final Color color; // Category accent colour (light + dark safe)
  final String nameEn;
  final String nameSi;
  final String nameTa;

  const CategoryMeta({
    required this.id,
    required this.icon,
    required this.color,
    required this.nameEn,
    required this.nameSi,
    required this.nameTa,
  });

  /// Resolves the display name for the given language code (si/en/ta).
  String name(String lang) => switch (lang) {
        'si' => nameSi,
        'ta' => nameTa,
        _ => nameEn,
      };
}

/// All nine categories with their icon + colour mapping (spec 2.5 / 5.3).
const List<CategoryMeta> kCategories = [
  CategoryMeta(
      id: ServiceCategory.electricity,
      icon: Icons.bolt_outlined,
      color: Color(0xFF854F0B),
      nameEn: 'Electricity',
      nameSi: 'විදුලිය',
      nameTa: 'மின்சாரம்'),
  CategoryMeta(
      id: ServiceCategory.water,
      icon: Icons.water_drop_outlined,
      color: Color(0xFF185FA5),
      nameEn: 'Water',
      nameSi: 'ජලය',
      nameTa: 'தண்ணீர்'),
  CategoryMeta(
      id: ServiceCategory.hospital,
      icon: Icons.local_hospital_outlined,
      color: Color(0xFFA32D2D),
      nameEn: 'Hospitals',
      nameSi: 'රෝහල්',
      nameTa: 'மருத்துவமனைகள்'),
  CategoryMeta(
      id: ServiceCategory.police,
      icon: Icons.shield_outlined,
      color: Color(0xFF3C3489),
      nameEn: 'Police',
      nameSi: 'පොලිසිය',
      nameTa: 'காவல்துறை'),
  CategoryMeta(
      id: ServiceCategory.court,
      icon: Icons.gavel_outlined,
      color: Color(0xFF72243E),
      nameEn: 'Courts',
      nameSi: 'අධිකරණ',
      nameTa: 'நீதிமன்றங்கள்'),
  CategoryMeta(
      id: ServiceCategory.school,
      icon: Icons.school_outlined,
      color: Color(0xFF3B6D11),
      nameEn: 'Schools',
      nameSi: 'පාසල්',
      nameTa: 'பள்ளிகள்'),
  CategoryMeta(
      id: ServiceCategory.government,
      icon: Icons.account_balance_outlined,
      color: Color(0xFF0F6E56),
      nameEn: 'Government',
      nameSi: 'රජයේ කාර්යාල',
      nameTa: 'அரசு அலுவலகங்கள்'),
  CategoryMeta(
      id: ServiceCategory.transport,
      icon: Icons.directions_bus_outlined,
      color: Color(0xFF534AB7),
      nameEn: 'Transport',
      nameSi: 'ප්‍රවාහනය',
      nameTa: 'போக்குவரத்து'),
  CategoryMeta(
      id: ServiceCategory.post,
      icon: Icons.local_post_office_outlined,
      color: Color(0xFF5F5E5A),
      nameEn: 'Post Office',
      nameSi: 'තැපැල්',
      nameTa: 'அஞ்சலகம்'),
];

/// Convenience lookup of [CategoryMeta] by enum id.
CategoryMeta categoryMeta(ServiceCategory id) =>
    kCategories.firstWhere((c) => c.id == id);

/// A Sri Lankan district with its parent province and the real-world
/// coordinates of its administrative capital (spec 4.4 — all 25). The
/// coordinates anchor service map pins and power GPS district detection.
class District {
  final String name;
  final String province;
  final double lat;
  final double lng;
  const District(this.name, this.province, this.lat, this.lng);
}

/// All 25 districts grouped by province with district-capital coordinates.
const List<District> kDistricts = [
  District('Colombo', 'Western', 6.9271, 79.8612),
  District('Gampaha', 'Western', 7.0917, 79.9999),
  District('Kalutara', 'Western', 6.5854, 79.9607),
  District('Kandy', 'Central', 7.2906, 80.6337),
  District('Matale', 'Central', 7.4675, 80.6234),
  District('Nuwara Eliya', 'Central', 6.9497, 80.7891),
  District('Galle', 'Southern', 6.0535, 80.2210),
  District('Matara', 'Southern', 5.9549, 80.5550),
  District('Hambantota', 'Southern', 6.1429, 81.1212),
  District('Jaffna', 'Northern', 9.6615, 80.0255),
  District('Kilinochchi', 'Northern', 9.3803, 80.3770),
  District('Mannar', 'Northern', 8.9810, 79.9044),
  District('Mullaitivu', 'Northern', 9.2671, 80.8142),
  District('Vavuniya', 'Northern', 8.7514, 80.4971),
  District('Batticaloa', 'Eastern', 7.7170, 81.7000),
  District('Ampara', 'Eastern', 7.2975, 81.6820),
  District('Trincomalee', 'Eastern', 8.5874, 81.2152),
  District('Kurunegala', 'North Western', 7.4818, 80.3609),
  District('Puttalam', 'North Western', 8.0362, 79.8283),
  District('Anuradhapura', 'North Central', 8.3114, 80.4037),
  District('Polonnaruwa', 'North Central', 7.9403, 81.0188),
  District('Badulla', 'Uva', 6.9934, 81.0550),
  District('Monaragala', 'Uva', 6.8714, 81.3487),
  District('Ratnapura', 'Sabaragamuwa', 6.7056, 80.3847),
  District('Kegalle', 'Sabaragamuwa', 7.2513, 80.3464),
];

/// Looks up a district by name (returns null when unknown).
District? districtByName(String name) {
  for (final d in kDistricts) {
    if (d.name == name) return d;
  }
  return null;
}

/// A national emergency hotline tile (spec 4.6 — Number Tiles table).
class EmergencyContact {
  final String nameKey; // Translation key for the service name
  final String number;
  final IconData icon;
  final Color color; // Tile background colour from spec table

  const EmergencyContact({
    required this.nameKey,
    required this.number,
    required this.icon,
    required this.color,
  });
}

/// The ten national hotlines, stored locally so the Emergency screen works
/// fully offline (spec 5.2).
const List<EmergencyContact> kEmergencyContacts = [
  EmergencyContact(
      nameKey: 'em_police',
      number: '119',
      icon: Icons.shield_outlined,
      color: Color(0xFFA32D2D)),
  EmergencyContact(
      nameKey: 'em_ambulance',
      number: '1990',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF185FA5)),
  EmergencyContact(
      nameKey: 'em_fire',
      number: '111',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFF854F0B)),
  EmergencyContact(
      nameKey: 'em_disaster',
      number: '117',
      icon: Icons.warning_amber_outlined,
      color: Color(0xFF3B6D11)),
  EmergencyContact(
      nameKey: 'em_women_child',
      number: '1938',
      icon: Icons.family_restroom_outlined,
      color: Color(0xFF72243E)),
  EmergencyContact(
      nameKey: 'em_mental',
      number: '1926',
      icon: Icons.psychology_outlined,
      color: Color(0xFF534AB7)),
  EmergencyContact(
      nameKey: 'em_ceb',
      number: '1987',
      icon: Icons.bolt_outlined,
      color: Color(0xFF0F6E56)),
  EmergencyContact(
      nameKey: 'em_water',
      number: '1954',
      icon: Icons.water_drop_outlined,
      color: Color(0xFF185FA5)),
  EmergencyContact(
      nameKey: 'em_tourist',
      number: '1912',
      icon: Icons.travel_explore_outlined,
      color: Color(0xFF3C3489)),
  EmergencyContact(
      nameKey: 'em_consumer',
      number: '1977',
      icon: Icons.gavel_outlined,
      color: Color(0xFF5F5E5A)),
];

/// The four home-screen quick-dial tiles (spec 4.5 — Emergency Section).
const List<EmergencyContact> kQuickDialContacts = [
  EmergencyContact(
      nameKey: 'em_police',
      number: '119',
      icon: Icons.shield_outlined,
      color: Color(0xFFA32D2D)),
  EmergencyContact(
      nameKey: 'em_ambulance_short',
      number: '110',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF185FA5)),
  EmergencyContact(
      nameKey: 'em_fire',
      number: '111',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFF854F0B)),
  EmergencyContact(
      nameKey: 'em_disaster',
      number: '117',
      icon: Icons.warning_amber_outlined,
      color: Color(0xFF3B6D11)),
];

/// App metadata used on Splash / About screens.
class AppInfo {
  AppInfo._();
  static const String appName = 'ලංකා සේවා';
  static const String appNameLatin = 'LankaSeva';
  static const String version = '1.0.0';
  static const String contactEmail = 'hello@lankseva.lk';
}

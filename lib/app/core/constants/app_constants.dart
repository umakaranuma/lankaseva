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

/// A Sri Lankan district with its parent province (spec 4.4 — all 25).
class District {
  final String name;
  final String province;
  const District(this.name, this.province);
}

/// All 25 districts grouped by province, in spec order.
const List<District> kDistricts = [
  District('Colombo', 'Western'),
  District('Gampaha', 'Western'),
  District('Kalutara', 'Western'),
  District('Kandy', 'Central'),
  District('Matale', 'Central'),
  District('Nuwara Eliya', 'Central'),
  District('Galle', 'Southern'),
  District('Matara', 'Southern'),
  District('Hambantota', 'Southern'),
  District('Jaffna', 'Northern'),
  District('Kilinochchi', 'Northern'),
  District('Mannar', 'Northern'),
  District('Mullaitivu', 'Northern'),
  District('Vavuniya', 'Northern'),
  District('Batticaloa', 'Eastern'),
  District('Ampara', 'Eastern'),
  District('Trincomalee', 'Eastern'),
  District('Kurunegala', 'North Western'),
  District('Puttalam', 'North Western'),
  District('Anuradhapura', 'North Central'),
  District('Polonnaruwa', 'North Central'),
  District('Badulla', 'Uva'),
  District('Monaragala', 'Uva'),
  District('Ratnapura', 'Sabaragamuwa'),
  District('Kegalle', 'Sabaragamuwa'),
];

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

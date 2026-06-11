import '../../core/constants/app_constants.dart';

/// ---------------------------------------------------------------------------
/// Service domain models — mirrors spec section 7 (Data Model).
/// Pure data classes only: no UI, no business logic beyond simple helpers.
/// ---------------------------------------------------------------------------

/// A string available in all three app languages (si / en / ta).
class LocalizedText {
  final String si;
  final String en;
  final String ta;

  const LocalizedText({required this.si, required this.en, required this.ta});

  /// Shorthand for data that is identical in every language (e.g. numbers).
  const LocalizedText.same(String value) : si = value, en = value, ta = value;

  /// Resolves the value for the given language code, falling back to English.
  String of(String lang) => switch (lang) {
        'si' => si,
        'ta' => ta,
        _ => en,
      };
}

/// One dialable phone number attached to a service.
class ServicePhone {
  final LocalizedText label; // e.g. "Hotline", "Fault line"
  final String number;
  final bool isPrimary; // Primary number used for the main Call button

  const ServicePhone({
    required this.label,
    required this.number,
    this.isPrimary = false,
  });
}

/// Weekly opening hours. `null` day entries mean closed that day.
class OpeningHours {
  final Map<int, (String open, String close)?> byWeekday; // 1=Mon … 7=Sun
  final bool isAlwaysOpen;
  final String? notes;

  const OpeningHours({
    this.byWeekday = const {},
    this.isAlwaysOpen = false,
    this.notes,
  });

  /// Standard government office hours preset (Mon–Fri 8:30–16:15).
  static const OpeningHours office = OpeningHours(byWeekday: {
    1: ('08:30', '16:15'),
    2: ('08:30', '16:15'),
    3: ('08:30', '16:15'),
    4: ('08:30', '16:15'),
    5: ('08:30', '16:15'),
  });

  /// 24×7 preset for hospitals, police, hotlines.
  static const OpeningHours always = OpeningHours(isAlwaysOpen: true);

  /// Returns true when the service is open at [now] — drives the live
  /// Open / Closed badge (spec 5.3).
  bool isOpenAt(DateTime now) {
    if (isAlwaysOpen) return true;
    final today = byWeekday[now.weekday];
    if (today == null) return false;
    final minutes = now.hour * 60 + now.minute;
    return minutes >= _toMinutes(today.$1) && minutes < _toMinutes(today.$2);
  }

  /// Parses "HH:mm" into minutes since midnight.
  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

/// A government service listing (the core entity of the app).
class Service {
  final String id;
  final LocalizedText name;
  final LocalizedText department;
  final ServiceCategory category;
  final String district;
  final List<ServicePhone> phones;
  final LocalizedText address;
  final double lat;
  final double lng;
  final OpeningHours hours;
  final String? website;
  final String? whatsapp;
  final bool isEmergency;
  /// Approximate distance from the user in km (static demo value — a real
  /// build would compute this from GPS).
  final double distanceKm;

  const Service({
    required this.id,
    required this.name,
    required this.department,
    required this.category,
    required this.district,
    required this.phones,
    required this.address,
    required this.lat,
    required this.lng,
    required this.hours,
    this.website,
    this.whatsapp,
    this.isEmergency = false,
    this.distanceKm = 0,
  });

  /// The primary phone number used by the one-tap Call button.
  ServicePhone get primaryPhone =>
      phones.firstWhere((p) => p.isPrimary, orElse: () => phones.first);
}

import 'dart:convert';

import 'package:http/http.dart' as http;

/// ---------------------------------------------------------------------------
/// GeocodingService
/// ---------------------------------------------------------------------------
/// Thin data-layer client for the free OpenStreetMap **Nominatim** geocoder
/// (no API key). Resolves a place query ("Kandy General Hospital, Kandy,
/// Sri Lanka") to its exact real-world coordinates so map pins point at the
/// actual buildings instead of approximate district positions.
///
/// Usage-policy compliance (https://operations.osmfoundation.org/policies/nominatim/):
///   • a descriptive User-Agent is always sent
///   • callers (GeocodingController) throttle to max 1 request/second
///   • results are cached on-device so each place is looked up only once
/// ---------------------------------------------------------------------------
class GeocodingService {
  GeocodingService._();

  static const _endpoint = 'https://nominatim.openstreetmap.org/search';
  static const _userAgent = 'LankaSeva/1.0 (hello@lankseva.lk)';

  /// Looks up [query] limited to Sri Lanka and returns `(lat, lng)` of the
  /// best match, or null when nothing was found / network failed. Never
  /// throws — callers always have the seeded coordinate as a fallback.
  static Future<(double, double)?> lookup(String query) async {
    try {
      final uri = Uri.parse(_endpoint).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'lk', // Constrain matches to Sri Lanka
      });
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final results = jsonDecode(response.body) as List;
      if (results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] ?? '');
      final lng = double.tryParse(first['lon'] ?? '');
      if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) return null;
      return (lat, lng);
    } catch (_) {
      return null; // Offline / timeout — seeded coordinate stays in use
    }
  }
}

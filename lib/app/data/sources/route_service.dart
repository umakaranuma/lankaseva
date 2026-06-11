import 'dart:convert';

import 'package:http/http.dart' as http;

/// A computed driving route: the polyline geometry plus totals.
class RouteResult {
  final List<(double lat, double lng)> points;
  final double distanceKm;
  final double durationMin;
  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });
}

/// ---------------------------------------------------------------------------
/// RouteService
/// ---------------------------------------------------------------------------
/// Thin data-layer client for the free public **OSRM** routing engine
/// (router.project-osrm.org — OpenStreetMap-based, no API key). Returns the
/// driving path between two coordinates as a polyline for flutter_map.
/// Controllers fall back to a straight line when the request fails, so the
/// route view always renders something useful offline.
/// ---------------------------------------------------------------------------
class RouteService {
  RouteService._();

  static const _endpoint = 'https://router.project-osrm.org/route/v1/driving';
  static const _userAgent = 'LankaSeva/1.0 (hello@lankseva.lk)';

  /// Fetches the driving route from (fromLat,fromLng) to (toLat,toLng).
  /// Returns null on any failure — never throws.
  static Future<RouteResult?> route(
      double fromLat, double fromLng, double toLat, double toLng) async {
    try {
      // OSRM takes lng,lat pairs (GeoJSON order).
      final uri = Uri.parse(
          '$_endpoint/$fromLng,$fromLat;$toLng,$toLat?overview=full&geometries=geojson');
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final route = routes.first as Map<String, dynamic>;

      final coords =
          (route['geometry']['coordinates'] as List).cast<List>();
      return RouteResult(
        // GeoJSON is [lng, lat] — flip to (lat, lng) for the app.
        points: [
          for (final p in coords)
            ((p[1] as num).toDouble(), (p[0] as num).toDouble())
        ],
        distanceKm: (route['distance'] as num).toDouble() / 1000,
        durationMin: (route['duration'] as num).toDouble() / 60,
      );
    } catch (_) {
      return null; // Offline / timeout — caller draws a straight line
    }
  }
}

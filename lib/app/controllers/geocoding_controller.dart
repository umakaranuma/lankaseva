import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/models/service_model.dart';
import '../data/sources/geocoding_service.dart';
import 'location_controller.dart';

/// ---------------------------------------------------------------------------
/// GeocodingController
/// ---------------------------------------------------------------------------
/// Resolves every service to its EXACT real-world position using the free
/// Nominatim geocoder and keeps the results reactive so map pins snap to
/// the true location the moment a lookup completes.
///
/// Responsibilities:
///   • per-service resolved coordinates (RxMap → markers rebuild live)
///   • persistent cache (each place is geocoded once, then served offline)
///   • polite request queue — max 1 request/second (Nominatim policy)
///   • sanity check: a result is accepted only if it actually falls inside
///     the service's district (rejects same-name matches in other towns)
///   • single coordinate rule for the whole app via [positionOf]
/// ---------------------------------------------------------------------------
class GeocodingController extends GetxController {
  static const _kCachePrefix = 'geo_';

  late SharedPreferences _prefs;

  /// Resolved exact coordinates by service id. Map markers observe this.
  final RxMap<String, (double, double)> resolved =
      <String, (double, double)>{}.obs;

  /// Pending lookup queue + in-flight guard (avoids duplicate requests).
  final Queue<Service> _queue = Queue<Service>();
  final Set<String> _queued = <String>{};
  bool _draining = false;

  /// Loads the persisted geocode cache; called from main().
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(_kCachePrefix)) continue;
      final parts = (_prefs.getString(key) ?? '').split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          resolved[key.substring(_kCachePrefix.length)] = (lat, lng);
        }
      }
    }
  }

  // -------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------

  /// The best known position for a service: exact geocoded coordinates
  /// when available, the seeded district-anchored estimate otherwise.
  (double, double) positionOf(Service s) =>
      resolved[s.id] ?? (s.lat, s.lng);

  /// Ensures every service in [services] is (or will be) geocoded.
  /// Already-resolved ids are skipped; the rest join the throttled queue.
  /// Safe to call on every map build — it is fully idempotent.
  void ensureResolved(List<Service> services) {
    for (final s in services) {
      if (resolved.containsKey(s.id) || _queued.contains(s.id)) continue;
      _queued.add(s.id);
      _queue.add(s);
    }
    _drainQueue();
  }

  // -------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------

  /// Works through the queue at 1 request/second (Nominatim usage policy).
  Future<void> _drainQueue() async {
    if (_draining) return; // Single drainer at a time
    _draining = true;
    try {
      while (_queue.isNotEmpty) {
        final service = _queue.removeFirst();
        await _resolveOne(service);
        if (_queue.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 1100));
        }
      }
    } finally {
      _draining = false;
    }
  }

  /// Geocodes one service: try "name, district, Sri Lanka" first, then the
  /// street address as a fallback query. Accepted results are validated
  /// against the service's district and persisted.
  Future<void> _resolveOne(Service s) async {
    var hit = await GeocodingService.lookup(
        '${s.name.en}, ${s.district}, Sri Lanka');
    hit ??= await GeocodingService.lookup(
        '${s.address.en}, ${s.district}, Sri Lanka');
    if (hit == null) return; // Keep seeded estimate

    // District sanity check: the matched point's nearest district capital
    // must be the service's own district, otherwise Nominatim matched a
    // same-name place elsewhere and the seeded estimate is safer.
    final nearest = Get.find<LocationController>()
        .nearestDistrict(hit.$1, hit.$2);
    final ownDistrict = districtByName(s.district);
    if (ownDistrict != null && nearest.name != ownDistrict.name) return;

    resolved[s.id] = hit;
    _prefs.setString('$_kCachePrefix${s.id}', '${hit.$1},${hit.$2}');
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../data/models/service_model.dart';
import 'app_controller.dart';
import 'geocoding_controller.dart';

/// ---------------------------------------------------------------------------
/// LocationController
/// ---------------------------------------------------------------------------
/// Owns everything GPS-related (spec 5.5 — Map & Location):
///   • the full runtime permission flow ("Use my location" → ask permission
///     → handle denied / permanently-denied / services-off states properly)
///   • the user's current latitude/longitude (reactive)
///   • auto district detection (nearest district capital to the GPS fix)
///   • real distance-to-service calculation used by lists and sorting
///
/// UI never calls Geolocator directly — every screen goes through these
/// functions, so permission handling stays consistent app-wide.
/// ---------------------------------------------------------------------------
class LocationController extends GetxController {
  /// Last known GPS fix (null until the user grants permission and a fix
  /// is acquired). All distance labels react to this.
  final Rxn<Position> position = Rxn<Position>();

  /// True while a GPS request is in flight (drives button spinners).
  final RxBool isLocating = false.obs;

  /// True when the user has a usable fix.
  bool get hasFix => position.value != null;

  // -------------------------------------------------------------------
  // Permission flow
  // -------------------------------------------------------------------

  /// Runs the complete permission + service check chain and returns true
  /// only when location can actually be read. Every failure mode gets a
  /// clear, actionable message instead of a silent no-op:
  ///   • location services off  → prompt to open device location settings
  ///   • permission denied      → request it (system dialog)
  ///   • denied forever         → prompt to open the app settings page
  Future<bool> ensurePermission() async {
    // 1. Device-level location services must be on.
    if (!await Geolocator.isLocationServiceEnabled()) {
      final open = await _askUser(
        title: 'location'.tr,
        message: 'location_services_off'.tr,
        actionLabel: 'open_settings'.tr,
      );
      if (open) await Geolocator.openLocationSettings();
      return false;
    }

    // 2. App-level permission.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Triggers the native OS permission dialog.
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // The OS will no longer show the dialog — guide to app settings.
      final open = await _askUser(
        title: 'location'.tr,
        message: 'location_denied_forever'.tr,
        actionLabel: 'open_settings'.tr,
      );
      if (open) await Geolocator.openAppSettings();
      return false;
    }

    if (permission == LocationPermission.denied) {
      Get.rawSnackbar(message: 'location_denied'.tr);
      return false;
    }

    return true; // whileInUse or always
  }

  /// Small reusable confirm dialog for the permission guidance prompts.
  Future<bool> _askUser({
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    final result = await Get.dialog<bool>(AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr)),
        FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(actionLabel)),
      ],
    ));
    return result == true;
  }

  // -------------------------------------------------------------------
  // GPS fix
  // -------------------------------------------------------------------

  /// Acquires the current position (permission flow included). Returns the
  /// fix, or null when permission/services were refused or GPS timed out.
  Future<Position?> getCurrentPosition() async {
    if (!await ensurePermission()) return null;
    isLocating.value = true;
    try {
      final fix = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // District-level is enough
          timeLimit: Duration(seconds: 15),
        ),
      );
      position.value = fix;
      return fix;
    } catch (_) {
      // Timeout / transient platform error — fall back to last known fix.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) position.value = last;
      return last;
    } finally {
      isLocating.value = false;
    }
  }

  // -------------------------------------------------------------------
  // District detection ("Use my location", spec 4.4)
  // -------------------------------------------------------------------

  /// Gets a GPS fix, resolves the nearest district capital and applies it
  /// as the active district. Returns true on success so the caller screen
  /// knows whether to continue its flow. Fully offline — no geocoding API.
  Future<bool> detectAndApplyDistrict() async {
    final fix = await getCurrentPosition();
    if (fix == null) return false;
    final district = nearestDistrict(fix.latitude, fix.longitude);
    Get.find<AppController>().changeDistrict(district.name);
    Get.rawSnackbar(
        message: '${district.name} ${'district'.tr}',
        duration: const Duration(seconds: 2));
    return true;
  }

  /// Nearest district capital to a coordinate (simple great-circle scan
  /// over the 25 known capitals — accurate enough for district assignment).
  District nearestDistrict(double lat, double lng) {
    District best = kDistricts.first;
    double bestMeters = double.infinity;
    for (final d in kDistricts) {
      final m = Geolocator.distanceBetween(lat, lng, d.lat, d.lng);
      if (m < bestMeters) {
        bestMeters = m;
        best = d;
      }
    }
    return best;
  }

  // -------------------------------------------------------------------
  // Distances
  // -------------------------------------------------------------------

  /// Real distance (km) from the user to a service, measured against the
  /// service's exact geocoded position when available. Falls back to the
  /// seeded estimate until a GPS fix exists, so distance labels and
  /// "Nearest" sorting always have a value.
  double distanceTo(Service s) {
    final fix = position.value;
    if (fix == null) return s.distanceKm;
    final (lat, lng) = Get.find<GeocodingController>().positionOf(s);
    return Geolocator.distanceBetween(fix.latitude, fix.longitude, lat, lng) /
        1000;
  }
}

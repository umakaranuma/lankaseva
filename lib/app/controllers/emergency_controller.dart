import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../data/sources/emergency_data_source.dart';

/// ---------------------------------------------------------------------------
/// EmergencyController
/// ---------------------------------------------------------------------------
/// Exposes the national emergency hotlines to the UI. Screens read these
/// getters instead of touching [EmergencyDataSource] directly; the data
/// source owns the `GET /api/emergency/` call.
/// ---------------------------------------------------------------------------
class EmergencyController extends GetxController {
  /// All hub hotlines (Emergency screen).
  List<EmergencyContact> get hotlines => EmergencyDataSource.hotlines;

  /// The home-screen quick-dial tiles.
  List<EmergencyContact> get quickDial => EmergencyDataSource.quickDial;

  /// Loads the hotlines from the backend (called by the splash bootstrap).
  Future<void> load() => EmergencyDataSource.load();
}

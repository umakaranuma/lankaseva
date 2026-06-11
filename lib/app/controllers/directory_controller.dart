import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../data/models/service_model.dart';
import '../data/sources/service_data_source.dart';
import 'app_controller.dart';
import 'geocoding_controller.dart';
import 'location_controller.dart';
import 'review_controller.dart';

/// Sort options for category listings (spec 4.7 — Sort bar).
enum ServiceSort { nearest, topRated, mostReviewed, openNow }

/// ---------------------------------------------------------------------------
/// DirectoryController
/// ---------------------------------------------------------------------------
/// Drives every directory-style listing in the app:
///   • Home → "Near you" list for the active district
///   • Category List screen (district filter + sort chips)
///   • Map screen (category filter chips + map/list toggle)
/// All filtering/sorting logic lives here; screens only render the results.
/// ---------------------------------------------------------------------------
class DirectoryController extends GetxController {
  /// Category currently being browsed on the Category List screen.
  final Rxn<ServiceCategory> activeCategory = Rxn<ServiceCategory>();

  /// Active sort on the Category List screen.
  final Rx<ServiceSort> sort = ServiceSort.nearest.obs;

  /// Category filter on the Map screen (null = all categories).
  final Rxn<ServiceCategory> mapCategory = Rxn<ServiceCategory>();

  /// Map screen presentation toggle: false = map, true = list (spec 4.10).
  final RxBool mapAsList = false.obs;

  AppController get _app => Get.find<AppController>();
  ReviewController get _reviews => Get.find<ReviewController>();
  LocationController get _location => Get.find<LocationController>();

  /// Real distance from the user when a GPS fix exists, seeded estimate
  /// otherwise — single distance rule for all sorting and labels.
  double distanceOf(Service s) => _location.distanceTo(s);

  // -------------------------------------------------------------------
  // Home
  // -------------------------------------------------------------------

  /// "Near you" services for the active district, closest first,
  /// capped at [limit] items (spec 4.5 — maximum 10).
  List<Service> nearbyServices({int limit = 10}) {
    final list = ServiceDataSource.services
        .where((s) => s.district == _app.district.value)
        .toList()
      ..sort((a, b) => distanceOf(a).compareTo(distanceOf(b)));
    return list.take(limit).toList();
  }

  // -------------------------------------------------------------------
  // Category List screen
  // -------------------------------------------------------------------

  /// Opens a category: remembers it and resets the sort to default.
  void openCategory(ServiceCategory category) {
    activeCategory.value = category;
    sort.value = ServiceSort.nearest;
  }

  /// Selects a sort chip on the Category List screen.
  void changeSort(ServiceSort value) => sort.value = value;

  /// Services in the active category + district, ordered by the active
  /// sort chip. "Open now" filters rather than sorts (matches spec intent).
  List<Service> categoryServices() {
    final cat = activeCategory.value;
    if (cat == null) return const [];
    var list = ServiceDataSource.services
        .where((s) => s.category == cat && s.district == _app.district.value)
        .toList();

    switch (sort.value) {
      case ServiceSort.nearest:
        list.sort((a, b) => distanceOf(a).compareTo(distanceOf(b)));
      case ServiceSort.topRated:
        list.sort((a, b) =>
            _reviews.averageFor(b.id).compareTo(_reviews.averageFor(a.id)));
      case ServiceSort.mostReviewed:
        list.sort(
            (a, b) => _reviews.countFor(b.id).compareTo(_reviews.countFor(a.id)));
      case ServiceSort.openNow:
        final now = DateTime.now();
        list = list.where((s) => s.hours.isOpenAt(now)).toList()
          ..sort((a, b) => distanceOf(a).compareTo(distanceOf(b)));
    }
    return list;
  }

  // -------------------------------------------------------------------
  // Map screen
  // -------------------------------------------------------------------

  /// Selects/deselects a category chip on the Map screen.
  void setMapCategory(ServiceCategory? category) =>
      mapCategory.value = mapCategory.value == category ? null : category;

  /// Flips between map view and list view.
  void toggleMapAsList() => mapAsList.toggle();

  /// Services plotted on the map for the active district + category filter.
  List<Service> mapServices() => ServiceDataSource.services
      .where((s) =>
          s.district == _app.district.value &&
          (mapCategory.value == null || s.category == mapCategory.value))
      .toList()
    ..sort((a, b) => distanceOf(a).compareTo(distanceOf(b)));

  // -------------------------------------------------------------------
  // Shared actions
  // -------------------------------------------------------------------

  /// Opens the platform map app pointed at the service's EXACT position
  /// (geocoded coordinates when resolved, seeded estimate otherwise).
  /// Also queues a geocode lookup so repeat opens get more accurate.
  void openServiceMap(Service s) {
    final geocoder = Get.find<GeocodingController>();
    geocoder.ensureResolved([s]);
    final (lat, lng) = geocoder.positionOf(s);
    _app.openMap(lat, lng, s.name.of(_app.language.value));
  }

  /// Builds the shareable text block for a service (spec 5.3 — Service
  /// sharing) and hands it to the platform share action.
  void shareService(Service s) {
    final lang = _app.language.value;
    _app.shareText('${s.name.of(lang)} — ${s.district}\n'
        '${'call'.tr}: ${s.primaryPhone.number}\n'
        '${s.address.of(lang)}\n'
        '— ${AppInfo.appNameLatin}');
  }

  /// Submits an incorrect-info report for a service. With no backend this
  /// simply acknowledges; production would POST /report/:serviceId.
  void reportIncorrectInfo(Service s) =>
      Get.rawSnackbar(message: 'report_sent'.tr);

  /// Acknowledges a "suggest a service" submission (POST /suggest in prod).
  void suggestService() => Get.rawSnackbar(message: 'report_sent'.tr);
}

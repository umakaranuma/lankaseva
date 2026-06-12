import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../data/models/service_model.dart';
import '../data/sources/service_data_source.dart';
import '../routes/app_pages.dart';
import 'app_controller.dart';
import 'geocoding_controller.dart';
import 'location_controller.dart';
import 'review_controller.dart';
import '../ui/widgets/common_widgets.dart';

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

  /// Page size for category listings (pagination, keeps long district
  /// lists fast and scannable).
  static const int categoryPageSize = 8;

  /// How many category results are currently visible (grows by page).
  final RxInt categoryVisible = categoryPageSize.obs;

  /// Opens a category: remembers it, resets sort AND pagination.
  void openCategory(ServiceCategory category) {
    activeCategory.value = category;
    sort.value = ServiceSort.nearest;
    categoryVisible.value = categoryPageSize;
  }

  /// Selects a sort chip; pagination restarts from the first page so the
  /// user always sees the new ordering from the top.
  void changeSort(ServiceSort value) {
    sort.value = value;
    categoryVisible.value = categoryPageSize;
  }

  /// Reveals the next page of category results.
  void loadMoreCategory() => categoryVisible.value += categoryPageSize;

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

  /// Opens the in-app route view for a service: the exact place pinned on
  /// OpenStreetMap with the driving path from the user's current location
  /// drawn when permission is granted (ServiceMapScreen handles the flow).
  void openServiceMap(Service s) {
    Get.find<GeocodingController>().ensureResolved([s]);
    Get.toNamed(Routes.serviceMap, arguments: s);
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

  /// Opens the full "Report incorrect info" form for a service (spec 5.3).
  void reportIncorrectInfo(Service s) =>
      Get.toNamed(Routes.reportInfo, arguments: s);

  /// Acknowledges a "suggest a service" submission (POST /suggest in prod).
  void suggestService() => AppToast.show('report_sent'.tr);
}

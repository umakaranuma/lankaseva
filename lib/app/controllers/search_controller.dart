import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/models/service_model.dart';
import '../data/sources/service_data_source.dart';
import 'app_controller.dart';

/// ---------------------------------------------------------------------------
/// ServiceSearchController
/// ---------------------------------------------------------------------------
/// Full-text search across the directory (spec 4.9). Scope: service name,
/// department, phone numbers, address, category and district — in every
/// language. Also owns the locally persisted recent-search history
/// (last 10, spec 4.9).
///
/// Named ServiceSearchController to avoid clashing with Material's
/// built-in SearchController class.
/// ---------------------------------------------------------------------------
class ServiceSearchController extends GetxController {
  static const _kRecent = 'recent_searches';

  late SharedPreferences _prefs;

  /// Live query text.
  final RxString query = ''.obs;

  /// Matching services for the current query.
  final RxList<Service> serviceResults = <Service>[].obs;

  /// Matching categories (grouped results — spec 4.9).
  final RxList<CategoryMeta> categoryResults = <CategoryMeta>[].obs;

  /// Matching district names.
  final RxList<String> districtResults = <String>[].obs;

  /// Last 10 searches, newest first.
  final RxList<String> recentSearches = <String>[].obs;

  /// Loads persisted recent searches.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    recentSearches.assignAll(_prefs.getStringList(_kRecent) ?? const []);
  }

  // -------------------------------------------------------------------
  // Search
  // -------------------------------------------------------------------

  /// Runs the search on every keystroke. Empty query clears results so the
  /// UI falls back to showing recent searches.
  void onQueryChanged(String text) {
    query.value = text;
    final q = text.trim().toLowerCase();
    if (q.isEmpty) {
      serviceResults.clear();
      categoryResults.clear();
      districtResults.clear();
      return;
    }

    final lang = Get.find<AppController>().language.value;

    // Services: match name / department / phone / address / district in
    // all languages (spec search scope).
    serviceResults.assignAll(ServiceDataSource.services.where((s) {
      bool hit(LocalizedText t) =>
          t.si.toLowerCase().contains(q) ||
          t.en.toLowerCase().contains(q) ||
          t.ta.toLowerCase().contains(q);
      return hit(s.name) ||
          hit(s.department) ||
          hit(s.address) ||
          s.district.toLowerCase().contains(q) ||
          s.phones.any((p) => p.number.contains(q)) ||
          categoryMeta(s.category).name(lang).toLowerCase().contains(q);
    }).take(30));

    // Categories.
    categoryResults.assignAll(kCategories.where((c) =>
        c.nameEn.toLowerCase().contains(q) ||
        c.nameSi.contains(text.trim()) ||
        c.nameTa.contains(text.trim())));

    // Districts.
    districtResults.assignAll(kDistricts
        .map((d) => d.name)
        .where((n) => n.toLowerCase().contains(q)));
  }

  /// True when a non-empty query produced zero hits (no-results state).
  bool get noResults =>
      query.value.trim().isNotEmpty &&
      serviceResults.isEmpty &&
      categoryResults.isEmpty &&
      districtResults.isEmpty;

  // -------------------------------------------------------------------
  // Recent searches (spec 4.9 — last 10, stored locally)
  // -------------------------------------------------------------------

  /// Records a successful search term when the user opens a result.
  void rememberSearch(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    recentSearches.remove(t);
    recentSearches.insert(0, t);
    if (recentSearches.length > 10) recentSearches.removeRange(10, recentSearches.length);
    _prefs.setStringList(_kRecent, recentSearches.toList());
  }

  /// Removes one entry via its × button.
  void removeRecent(String term) {
    recentSearches.remove(term);
    _prefs.setStringList(_kRecent, recentSearches.toList());
  }

  /// Clears the whole history (Settings → Data & Privacy).
  void clearHistory() {
    recentSearches.clear();
    _prefs.setStringList(_kRecent, const []);
  }
}

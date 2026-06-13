import '../models/service_model.dart';
import '../../core/config/api_config.dart';
import 'api_client.dart';

/// ---------------------------------------------------------------------------
/// ServiceDataSource
/// ---------------------------------------------------------------------------
/// In-memory cache of the government-places directory. There is NO bundled /
/// static data: the list is empty until [load] fills it from the backend
/// (`GET /api/services/`). Every screen reads [services] / [byId], so the
/// whole app shows live data only.
///
/// Controllers MUST go through this class — never hold raw data themselves.
/// ---------------------------------------------------------------------------
class ServiceDataSource {
  ServiceDataSource._();

  /// The directory, populated exclusively from the API by [load].
  static final List<Service> services = <Service>[];

  /// True once a successful API load has completed.
  static bool loaded = false;

  /// Loads the full directory from `GET /api/services/`. Throws on failure
  /// so the caller (splash bootstrap) can show an error/retry state instead
  /// of silently showing nothing.
  static Future<void> load() async {
    final rows = await ApiClient.getAllPages(ApiConfig.services);
    services
      ..clear()
      ..addAll(rows.map(Service.fromJson));
    loaded = true;
  }

  /// Fetches one place from `GET /api/services/{id}/` and refreshes the
  /// cached copy in [services]. Returns the fresh model. Throws on failure.
  static Future<Service> fetchById(String id) async {
    final json = await ApiClient.get(ApiConfig.service(id)) as Map<String, dynamic>;
    final fresh = Service.fromJson(json);
    final i = services.indexWhere((s) => s.id == fresh.id);
    if (i != -1) services[i] = fresh;
    return fresh;
  }

  /// Finds a single service by id (returns null when not found).
  static Service? byId(String id) {
    for (final s in services) {
      if (s.id == id) return s;
    }
    return null;
  }
}

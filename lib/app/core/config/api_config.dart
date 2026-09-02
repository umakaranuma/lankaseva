import 'app_environment.dart';

/// ---------------------------------------------------------------------------
/// ApiConfig — the single place that defines the backend origin and every
/// REST endpoint path used by the app.
///
/// Nothing else in the codebase should hard-code an `/api/...` string or a
/// host: data sources and controllers reference these members so the whole
/// integration can be re-pointed (live, production, a teammate's LAN IP) from
/// one place — the `kEnvironment` switch in `lib/main.dart` and the matching
/// `.env.<name>` file.
/// ---------------------------------------------------------------------------
class ApiConfig {
  ApiConfig._();

  /// Backend origin (scheme + host + port), no trailing slash, no `/api`.
  /// Value of `API_BASE_URL` from the `.env` file selected by `kEnvironment`
  /// (see [AppEnvironment]).
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  /// Network timeout for a single request.
  static const Duration timeout = Duration(seconds: 8);

  /// Max rows the directory/reviews list endpoints return per request
  /// (matches the backend's DefaultPagination.max_page_size).
  static const int pageLimit = 500;

  // ---- Auth -----------------------------------------------------------
  static const String otpSend = '/api/auth/otp/send/';
  static const String otpVerify = '/api/auth/otp/verify/';
  static const String profile = '/api/auth/profile/';
  static const String logout = '/api/auth/logout/';
  static const String account = '/api/auth/account/';

  // ---- Services (government places) -----------------------------------
  /// Whole directory in one page (Home, Category list, Map, Search all read
  /// the synced result of this call).
  static const String services = '/api/services/?limit=$pageLimit';

  /// Single service document (detail screen + map pin): phones, opening
  /// hours, lat/lng, website — everything the single view renders.
  static String service(String id) => '/api/services/$id/';

  // ---- Emergency hotlines --------------------------------------------
  static const String emergency = '/api/emergency/';

  // ---- Reports --------------------------------------------------------
  static const String reports = '/api/reports/';

  // ---- Reviews --------------------------------------------------------
  static const String reviews = '/api/reviews/?limit=$pageLimit';
  static const String reviewsCreate = '/api/reviews/';
  static String review(String id) => '/api/reviews/$id/';
  static String reviewHelpful(String id) => '/api/reviews/$id/helpful/';
}

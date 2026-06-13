import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// ---------------------------------------------------------------------------
/// ApiConfig — the single place that defines the backend origin and every
/// REST endpoint path used by the app.
///
/// Nothing else in the codebase should hard-code an `/api/...` string or a
/// host: data sources and controllers reference these members so the whole
/// integration can be re-pointed (staging, production, a teammate's LAN IP)
/// from one file or one `--dart-define`.
/// ---------------------------------------------------------------------------
class ApiConfig {
  ApiConfig._();

  /// Backend origin (scheme + host + port), no trailing slash.
  ///
  /// Resolution order:
  ///   1. `--dart-define=API_BASE_URL=https://api.lankaseva.lk` (prod/staging)
  ///   2. Android emulator → `http://10.0.2.2:8000` (reaches the host machine)
  ///   3. Everything else (desktop/web/iOS sim) → `http://127.0.0.1:8000`
  ///
  /// For a physical phone on the same Wi-Fi, pass your PC's LAN IP:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.x:8000
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://retha-unbickering-ardella.ngrok-free.dev';
    }
    return 'https://retha-unbickering-ardella.ngrok-free.dev';
  }

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

  // ---- Reviews --------------------------------------------------------
  static const String reviews = '/api/reviews/?limit=$pageLimit';
  static const String reviewsCreate = '/api/reviews/';
  static String review(String id) => '/api/reviews/$id/';
  static String reviewHelpful(String id) => '/api/reviews/$id/helpful/';
}

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ---------------------------------------------------------------------------
/// AppEnvironment — which backend the app talks to.
///
/// Pick the environment in ONE place: the `kEnvironment` constant at the top of
/// `lib/main.dart`. On startup `main()` calls [load], which reads the matching
/// `.env.<name>` file (bundled as an asset). Everything else reads [apiBaseUrl]
/// (via [ApiConfig]).
///
///   AppEnv.development -> .env.development
///   AppEnv.live        -> .env.live
///   AppEnv.production  -> .env.production
/// ---------------------------------------------------------------------------
enum AppEnv {
  development('.env.development'),
  live('.env.live'),
  production('.env.production');

  const AppEnv(this.fileName);

  /// Asset path of this environment's dotenv file.
  final String fileName;
}

class AppEnvironment {
  AppEnvironment._();

  static AppEnv _current = AppEnv.development;

  /// The active environment.
  static AppEnv get current => _current;

  /// Short lowercase name, e.g. for logs / a debug banner.
  static String get name => _current.name;

  /// Loads the `.env` file for [env]. Call once from `main()` after
  /// `WidgetsFlutterBinding.ensureInitialized()` and before any API call.
  static Future<void> load(AppEnv env) async {
    _current = env;
    await dotenv.load(fileName: env.fileName);
  }

  /// Backend origin (scheme + host + port) — NO trailing slash, NO `/api`.
  /// Comes from `API_BASE_URL` in the loaded `.env` file; falls back to a
  /// local address if the key is missing or dotenv was not loaded.
  static String get apiBaseUrl {
    final url = dotenv.maybeGet('API_BASE_URL');
    return (url != null && url.isNotEmpty) ? url : _localFallback;
  }

  /// Any other key from the loaded `.env` file (returns null if absent).
  static String? value(String key) => dotenv.maybeGet(key);

  static String get _localFallback =>
      (!kIsWeb && Platform.isAndroid) ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000';
}

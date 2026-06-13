import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../core/config/api_config.dart';

/// ---------------------------------------------------------------------------
/// ApiClient — thin wrapper over the LankaSeva backend REST API.
///
/// Owns the base URL, the persisted auth token and JSON encoding/decoding.
/// All remote calls in the app go through this class so connectivity
/// failures surface as a single [ApiException] type the callers can catch
/// to fall back to the offline data set.
/// ---------------------------------------------------------------------------
class ApiException implements Exception {
  final int? statusCode;
  final dynamic body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}

class ApiClient {
  ApiClient._();

  static const _kTokenKey = 'auth_token';
  static const _timeout = ApiConfig.timeout;

  /// Backend origin — defined once in [ApiConfig.baseUrl].
  static String get baseUrl => ApiConfig.baseUrl;

  static String? _token;

  /// Restores the persisted token; call once at startup.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
  }

  static bool get hasToken => _token != null;

  static Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_kTokenKey);
    } else {
      await prefs.setString(_kTokenKey, token);
    }
  }

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (_token != null) 'Authorization': 'Token $_token',
      };

  static dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    // A 401 means our stored token is no longer valid (expired, revoked, or
    // the server DB was reset). Drop it so the app falls back to anonymous
    // and the next protected action prompts a fresh login.
    if (res.statusCode == 401 && _token != null) {
      setToken(null);
      try {
        Get.find<AuthController>().logout();
      } catch (_) {}
    }
    throw ApiException(res.statusCode, body);
  }

  static Future<dynamic> get(String path) async =>
      _decode(await http
          .get(Uri.parse('$baseUrl$path'), headers: _headers())
          .timeout(_timeout));

  static Future<dynamic> post(String path, [Map<String, dynamic>? data]) async =>
      _decode(await http
          .post(Uri.parse('$baseUrl$path'),
              headers: _headers(), body: jsonEncode(data ?? {}))
          .timeout(_timeout));

  static Future<dynamic> put(String path, Map<String, dynamic> data) async =>
      _decode(await http
          .put(Uri.parse('$baseUrl$path'),
              headers: _headers(), body: jsonEncode(data))
          .timeout(_timeout));

  static Future<dynamic> delete(String path) async =>
      _decode(await http
          .delete(Uri.parse('$baseUrl$path'), headers: _headers())
          .timeout(_timeout));

  /// Follows DRF pagination (`results` + `next`) until all rows are loaded.
  static Future<List<Map<String, dynamic>>> getAllPages(String path) async {
    final items = <Map<String, dynamic>>[];
    String? url = '$baseUrl$path';
    while (url != null) {
      try {
        final res = await http
            .get(Uri.parse(url), headers: _headers())
            .timeout(_timeout);
        final data = _decode(res) as Map<String, dynamic>;
        items.addAll((data['results'] as List).cast<Map<String, dynamic>>());
        url = data['next'] as String?;
      } on ApiException catch (e) {
        if (e.statusCode == 401) continue; // Token dropped by _decode, retry!
        rethrow;
      }
    }
    return items;
  }
}

import '../../core/config/api_config.dart';
import 'api_client.dart';

/// ---------------------------------------------------------------------------
/// AuthDataSource
/// ---------------------------------------------------------------------------
/// Owns the authentication endpoints and the API session token. The
/// AuthController holds the wizard/session STATE and calls these functions —
/// it never touches ApiClient directly.
/// ---------------------------------------------------------------------------
class AuthDataSource {
  AuthDataSource._();

  /// Restores the persisted token at startup.
  static Future<void> init() => ApiClient.init();

  /// True when an API session token is present.
  static bool get hasToken => ApiClient.hasToken;

  /// Stores (or clears, when null) the session token.
  static Future<void> setToken(String? token) => ApiClient.setToken(token);

  /// `POST /api/auth/otp/send/` — returns the response (incl. debug_otp in dev).
  static Future<Map<String, dynamic>> sendOtp(String phone) async =>
      (await ApiClient.post(ApiConfig.otpSend, {'phone': phone}))
          as Map<String, dynamic>;

  /// `POST /api/auth/otp/verify/` — returns token + user + is_new_user.
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async =>
      (await ApiClient.post(ApiConfig.otpVerify, {'phone': phone, 'otp': otp}))
          as Map<String, dynamic>;

  /// `GET /api/auth/profile/` — current profile from the database.
  static Future<Map<String, dynamic>> getProfile() async =>
      (await ApiClient.get(ApiConfig.profile)) as Map<String, dynamic>;

  /// `PUT /api/auth/profile/` — updates the display name; returns the saved row.
  static Future<Map<String, dynamic>> updateProfile(String displayName) async =>
      (await ApiClient.put(ApiConfig.profile, {'display_name': displayName}))
          as Map<String, dynamic>;

  /// `POST /api/auth/logout/` — revokes the server-side token.
  static Future<void> logout() => ApiClient.post(ApiConfig.logout);

  /// `DELETE /api/auth/account/` — deletes the account (cascades reviews).
  static Future<void> deleteAccount() => ApiClient.delete(ApiConfig.account);
}

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';

/// ---------------------------------------------------------------------------
/// AuthController
/// ---------------------------------------------------------------------------
/// OTP authentication flow for Sri Lankan (+94) mobile numbers (spec 4.13).
/// Three steps managed as reactive state:
///   1. phone entry  → sendOtp()
///   2. OTP entry    → verifyOtp() (60 s resend countdown)
///   3. display name → completeProfile() (first login only)
///
/// NOTE: This build has no backend, so the OTP is generated locally and
/// surfaced in a snackbar to simulate the SMS. Swapping in the real
/// `/auth/otp/send` + `/auth/otp/verify` endpoints only touches this file —
/// no UI changes needed (that is the point of the controller layer).
/// ---------------------------------------------------------------------------
class AuthController extends GetxController {
  static const _kUserPrefix = 'auth_user_';

  late SharedPreferences _prefs;

  /// Logged-in user, or null while signed out.
  final Rxn<AppUser> user = Rxn<AppUser>();

  /// Login wizard step: 0 = phone, 1 = OTP, 2 = display name.
  final RxInt step = 0.obs;

  /// 9-digit local phone number being verified (without +94).
  final RxString phone = ''.obs;

  /// OTP digits typed so far (max 6).
  final RxString otpInput = ''.obs;

  /// Validation / error message shown under the active field.
  final RxString error = ''.obs;

  /// Seconds remaining before "Resend OTP" re-enables.
  final RxInt resendCountdown = 0.obs;

  /// Route to return to after a successful login (e.g. Write Review).
  String? pendingRedirect;

  String _expectedOtp = '';
  Timer? _resendTimer;

  /// True when a verified user session exists.
  bool get isLoggedIn => user.value != null;

  // -------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------

  /// Restores a persisted session; called from main() before runApp.
  /// Persisted user fields (kept in one list so save/restore/clear match).
  static const _userFields = [
    'id',
    'phoneHash',
    'displayName',
    'avatarPath',
    'createdAt',
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final map = <String, String>{};
    for (final field in _userFields) {
      final v = _prefs.getString('$_kUserPrefix$field');
      if (v != null) map[field] = v;
    }
    user.value = AppUser.fromMap(map);
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  // -------------------------------------------------------------------
  // Step 1 — phone number
  // -------------------------------------------------------------------

  /// Updates the phone field as the user types (digits only, max 9).
  void onPhoneChanged(String value) {
    phone.value = value.replaceAll(RegExp(r'\D'), '');
    error.value = '';
  }

  /// Validates the number and "sends" the OTP (locally generated here);
  /// moves the wizard to the OTP step and starts the resend countdown.
  void sendOtp() {
    if (!RegExp(r'^7\d{8}$').hasMatch(phone.value)) {
      error.value = 'invalid_phone'.tr;
      return;
    }
    _expectedOtp =
        List.generate(6, (_) => Random().nextInt(10)).join(); // Demo OTP
    otpInput.value = '';
    error.value = '';
    step.value = 1;
    _startResendCountdown();
    // Simulated SMS delivery — replace with POST /auth/otp/send in prod.
    Get.rawSnackbar(
        message: 'SMS (demo): Your LankaSeva code is $_expectedOtp',
        duration: const Duration(seconds: 6));
  }

  /// Re-sends the OTP once the 60-second countdown has elapsed (spec 4.13).
  void resendOtp() {
    if (resendCountdown.value > 0) return;
    sendOtp();
  }

  /// Restarts the 60 s resend timer.
  void _startResendCountdown() {
    resendCountdown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCountdown.value <= 1) {
        resendCountdown.value = 0;
        t.cancel();
      } else {
        resendCountdown.value--;
      }
    });
  }

  // -------------------------------------------------------------------
  // Step 2 — OTP
  // -------------------------------------------------------------------

  /// Records OTP digits as typed; auto-verifies when 6 digits are present.
  void onOtpChanged(String value) {
    otpInput.value = value.replaceAll(RegExp(r'\D'), '');
    error.value = '';
    if (otpInput.value.length == 6) verifyOtp();
  }

  /// Checks the entered code. New users continue to the display-name step;
  /// returning users are logged straight in.
  void verifyOtp() {
    if (otpInput.value != _expectedOtp) {
      error.value = 'invalid_otp'.tr;
      return;
    }
    final hash = _hashPhone('+94${phone.value}');
    // Returning user on this device → restore name and finish.
    final savedName = _prefs.getString('name_for_$hash');
    if (savedName != null) {
      _createSession(hash, savedName);
    } else {
      step.value = 2; // First time — ask for a display name.
    }
  }

  // -------------------------------------------------------------------
  // Step 3 — display name (first login only)
  // -------------------------------------------------------------------

  /// Saves the public display name and completes the login.
  void completeProfile(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      error.value = 'display_name_hint'.tr;
      return;
    }
    final hash = _hashPhone('+94${phone.value}');
    _prefs.setString('name_for_$hash', trimmed);
    _createSession(hash, trimmed);
  }

  /// Builds + persists the session, then returns to the pending screen.
  /// A previously saved profile photo for this number is restored.
  void _createSession(String phoneHash, String displayName) {
    final u = AppUser(
      id: phoneHash,
      phoneHash: phoneHash,
      displayName: displayName,
      avatarPath: _prefs.getString('avatar_for_$phoneHash'),
      createdAt: DateTime.now(),
    );
    user.value = u;
    u.toMap().forEach((k, v) => _prefs.setString('$_kUserPrefix$k', v));
    _resetWizard();
    final redirect = pendingRedirect;
    pendingRedirect = null;
    Get.back(); // Close login screen
    if (redirect != null) Get.toNamed(redirect);
  }

  // -------------------------------------------------------------------
  // Profile management
  // -------------------------------------------------------------------

  /// Renames the public display name shown on reviews (Profile screen).
  void updateDisplayName(String name) {
    final u = user.value;
    if (u == null || name.trim().length < 2) return;
    u.displayName = name.trim();
    user.refresh();
    _prefs.setString('${_kUserPrefix}displayName', u.displayName);
    _prefs.setString('name_for_${u.phoneHash}', u.displayName);
  }

  /// Opens the platform photo picker and sets the chosen image as the
  /// profile photo. The image is copied into the app's documents folder
  /// (gallery cache paths are temporary), persisted on the session AND
  /// keyed to the phone hash so it survives logout/login.
  Future<void> pickAvatar() async {
    final u = user.value;
    if (u == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Avatar-sized — keeps the copy small
      maxHeight: 600,
      imageQuality: 85,
    );
    if (picked == null) return; // User cancelled the picker

    final docs = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final dest = File('${docs.path}/avatar_${u.phoneHash}.$ext');
    await File(picked.path).copy(dest.path);

    u.avatarPath = dest.path;
    user.refresh();
    _prefs.setString('${_kUserPrefix}avatarPath', dest.path);
    _prefs.setString('avatar_for_${u.phoneHash}', dest.path);
  }

  /// Removes the profile photo and falls back to the initials avatar.
  Future<void> removeAvatar() async {
    final u = user.value;
    if (u == null || u.avatarPath == null) return;
    try {
      await File(u.avatarPath!).delete();
    } catch (_) {} // Already gone — ignore
    u.avatarPath = null;
    user.refresh();
    _prefs.remove('${_kUserPrefix}avatarPath');
    _prefs.remove('avatar_for_${u.phoneHash}');
  }

  /// Signs out, clearing the persisted session (bookmarks are kept —
  /// they are device-level, not account-level; the photo stays keyed to
  /// the phone number so it returns on next login).
  void logout() {
    user.value = null;
    for (final field in _userFields) {
      _prefs.remove('$_kUserPrefix$field');
    }
    _resetWizard();
  }

  /// Permanently deletes the account (Settings → destructive action),
  /// including the stored name and profile photo.
  void deleteAccount() {
    final u = user.value;
    if (u != null) {
      _prefs.remove('name_for_${u.phoneHash}');
      removeAvatar();
    }
    logout();
  }

  /// Clears wizard state so the login screen always opens at step 1.
  void _resetWizard() {
    step.value = 0;
    phone.value = '';
    otpInput.value = '';
    error.value = '';
    resendCountdown.value = 0;
    _resendTimer?.cancel();
  }

  /// Lightweight stand-in for SHA-256 phone hashing (spec: phone stored
  /// hashed, never displayed). Real build: crypto package server-side.
  String _hashPhone(String phone) =>
      'u${phone.codeUnits.fold<int>(17, (h, c) => h * 31 + c).toRadixString(16)}';
}

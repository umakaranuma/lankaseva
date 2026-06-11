import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/service_model.dart';
import '../data/sources/service_data_source.dart';
import '../routes/app_pages.dart';
import '../ui/widgets/app_sheets.dart';

/// ---------------------------------------------------------------------------
/// AppController
/// ---------------------------------------------------------------------------
/// Global application controller (permanent — registered once in main()).
/// Owns cross-cutting state and behaviour:
///   • theme mode (light / dark / system) with persistence
///   • app language (si / en / ta) with live locale switching
///   • selected district
///   • onboarding-completed flag and startup routing
///   • saved (bookmarked) services
///   • notification preference toggles
///   • shared device actions: one-tap calling, open URL, open map, share text
///
/// UI screens never touch SharedPreferences or url_launcher directly —
/// they call these functions.
/// ---------------------------------------------------------------------------
class AppController extends GetxController {
  // ---- Persistence keys ----
  static const _kLanguage = 'app_language';
  static const _kDistrict = 'app_district';
  static const _kTheme = 'app_theme';
  static const _kOnboarded = 'app_onboarded';
  static const _kSaved = 'app_saved_services';
  static const _kNotifPrefix = 'app_notif_';

  late SharedPreferences _prefs;

  // ---- Reactive state ----
  /// Current language code: 'si' | 'en' | 'ta'.
  final RxString language = 'en'.obs;

  /// Currently selected district name (one of kDistricts).
  final RxString district = 'Colombo'.obs;

  /// Active theme mode.
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// True once onboarding + language + district were completed.
  final RxBool onboarded = false.obs;

  /// Bookmarked service ids (Profile → Saved Services).
  final RxSet<String> savedServiceIds = <String>{}.obs;

  /// Notification preference toggles (spec 4.15), keyed by setting id.
  final RxMap<String, bool> notifPrefs = <String, bool>{
    'service_updates': true,
    'emergency': true,
    'replies': false,
  }.obs;

  /// Index of the active bottom-navigation tab on the main shell.
  final RxInt currentTab = 0.obs;

  // -------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------

  /// Loads persisted preferences before the first frame; called from main().
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    language.value = _prefs.getString(_kLanguage) ?? 'en';
    district.value = _prefs.getString(_kDistrict) ?? 'Colombo';
    onboarded.value = _prefs.getBool(_kOnboarded) ?? false;
    themeMode.value = switch (_prefs.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    savedServiceIds.addAll(_prefs.getStringList(_kSaved) ?? const []);
    for (final key in notifPrefs.keys) {
      notifPrefs[key] = _prefs.getBool('$_kNotifPrefix$key') ?? notifPrefs[key]!;
    }
  }

  /// Route to land on after the splash delay: onboarding on first launch,
  /// the main shell for returning users (spec 4.1).
  String get startRoute =>
      onboarded.value ? Routes.main : Routes.onboarding;

  // -------------------------------------------------------------------
  // Language / theme / district
  // -------------------------------------------------------------------

  /// Switches the app language and updates every visible string immediately.
  void changeLanguage(String code) {
    language.value = code;
    _prefs.setString(_kLanguage, code);
    Get.updateLocale(Locale(code));
  }

  /// Switches theme mode (light / dark / system) and persists the choice.
  void changeTheme(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _prefs.setString(
        _kTheme,
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          _ => 'system'
        });
  }

  /// Sets the active district; all district-filtered lists react via Obx.
  void changeDistrict(String name) {
    district.value = name;
    _prefs.setString(_kDistrict, name);
  }

  /// Marks first-run setup complete and enters the main shell.
  void completeOnboarding() {
    onboarded.value = true;
    _prefs.setBool(_kOnboarded, true);
    Get.offAllNamed(Routes.main);
  }

  /// Switches the active bottom-navigation tab.
  void changeTab(int index) => currentTab.value = index;

  // -------------------------------------------------------------------
  // Saved services
  // -------------------------------------------------------------------

  /// True when the service is bookmarked.
  bool isSaved(String serviceId) => savedServiceIds.contains(serviceId);

  /// Adds/removes a bookmark and persists the set, with a feedback toast.
  void toggleSaved(String serviceId) {
    if (!savedServiceIds.remove(serviceId)) {
      savedServiceIds.add(serviceId);
      _toast('saved_toast'.tr);
    } else {
      _toast('unsaved_toast'.tr);
    }
    _prefs.setStringList(_kSaved, savedServiceIds.toList());
  }

  /// Resolves the bookmarked ids into full Service objects for the Profile.
  List<Service> get savedServices => savedServiceIds
      .map(ServiceDataSource.byId)
      .whereType<Service>()
      .toList();

  /// Clears all bookmarks (Settings → Data & Privacy).
  void clearSavedServices() {
    savedServiceIds.clear();
    _prefs.setStringList(_kSaved, const []);
    _toast('cleared'.tr);
  }

  // -------------------------------------------------------------------
  // Notification preferences
  // -------------------------------------------------------------------

  /// Flips one notification toggle and persists it (spec 5.8 — each type
  /// independently toggleable).
  void toggleNotif(String key) {
    notifPrefs[key] = !(notifPrefs[key] ?? false);
    _prefs.setBool('$_kNotifPrefix$key', notifPrefs[key]!);
  }

  // -------------------------------------------------------------------
  // Device actions (shared by every screen)
  // -------------------------------------------------------------------

  /// One-tap calling with the mandatory confirmation (spec 4.5 / 4.6),
  /// presented as a bottom sheet (app rule: no popup dialogs), then hands
  /// off to the platform dialer.
  Future<void> callNumber(String number) async {
    final confirmed = await showConfirmSheet(
      title: 'call_number'.trParams({'number': number}),
      confirmLabel: 'call'.tr,
      icon: Icons.phone,
    );
    if (confirmed) {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _toast(number); // Desktop/emulator fallback: surface the number
      }
    }
  }

  /// Opens an external URL (websites, store links) in the system browser.
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Hands off to Google/Apple Maps for navigation (spec 5.5).
  Future<void> openMap(double lat, double lng, String label) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await openUrl(uri.toString());
  }

  /// Opens the native platform share sheet (WhatsApp, SMS, email, …) with
  /// the given text — used for service cards, emergency lists and reviews.
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Lightweight bottom snackbar used for all feedback toasts.
  void _toast(String message) {
    Get.rawSnackbar(message: message, duration: const Duration(seconds: 2));
  }
}

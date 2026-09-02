import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/config/api_config.dart';
import 'app/core/config/app_environment.dart';
import 'app/controllers/app_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/directory_controller.dart';
import 'app/controllers/emergency_controller.dart';
import 'app/controllers/geocoding_controller.dart';
import 'app/controllers/location_controller.dart';
import 'app/controllers/notification_controller.dart';
import 'app/controllers/report_controller.dart';
import 'app/controllers/review_controller.dart';
import 'app/controllers/search_controller.dart';
import 'app/core/localization/app_translations.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///  ENVIRONMENT SWITCH — change this one line, then run/build normally.
///
///    AppEnv.development  → .env.development  (local backend)
///    AppEnv.live         → .env.live
///    AppEnv.production    → .env.production
///
///  `flutter run`, `flutter build apk --release`, etc. all read this.
/// ═══════════════════════════════════════════════════════════════════════════
const AppEnv kEnvironment = AppEnv.development;

/// LankaSeva entry point. Loads the [kEnvironment] `.env` file, then boots.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnvironment.load(kEnvironment);

  if (kDebugMode) {
    debugPrint('LankaSeva • env=${AppEnvironment.name} • api=${ApiConfig.baseUrl}');
  }

  // ---- Controller registration (single source of truth for all state) ----
  final app = Get.put(AppController(), permanent: true);
  final auth = Get.put(AuthController(), permanent: true);
  Get.put(ReviewController(), permanent: true);
  final location = Get.put(LocationController(), permanent: true);
  final geocoder = Get.put(GeocodingController(), permanent: true);
  Get.put(DirectoryController(), permanent: true);
  Get.put(EmergencyController(), permanent: true);
  final search = Get.put(ServiceSearchController(), permanent: true);
  final notifications = Get.put(NotificationController(), permanent: true);
  Get.put(ReportController(), permanent: true);

  // Load only LOCAL persisted state before the first frame (preferences,
  // session token, search history, etc.). The actual content — services,
  // hotlines and reviews — is fetched from the backend by the SplashScreen
  // bootstrap, which shows a loading/error state. There is no bundled data.
  // ApiClient token is restored inside auth.init() so it is ready before the
  // splash's remote loads run.
  await Future.wait([
    app.init(),
    auth.init(),
    search.init(),
    geocoder.init(),
    notifications.init(),
    // Silently restores a GPS fix when location permission was already
    // granted, so "Near you" distances are real on the first frame.
    location.init(),
  ]);

  runApp(LankaSevaApp(initialLanguage: app.language.value));
}

/// Root widget: GetMaterialApp with light/dark themes from the design
/// system, GetX routing and live-switchable localisation.
class LankaSevaApp extends StatelessWidget {
  final String initialLanguage;
  const LankaSevaApp({super.key, required this.initialLanguage});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    return Obx(() => GetMaterialApp(
          title: 'LankaSeva',
          debugShowCheckedModeBanner: false,
          // Design-system themes (spec 2.1 / 2.2) + persisted mode toggle.
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: app.themeMode.value,
          // Trilingual UI (spec 5.6) — locale follows the controller.
          translations: AppTranslations(),
          locale: Locale(initialLanguage),
          fallbackLocale: const Locale('en'),
          // Navigation table (spec section 6).
          initialRoute: Routes.splash,
          getPages: AppPages.pages,
        ));
  }
}

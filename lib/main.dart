import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/controllers/app_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/directory_controller.dart';
import 'app/controllers/geocoding_controller.dart';
import 'app/controllers/location_controller.dart';
import 'app/controllers/notification_controller.dart';
import 'app/controllers/report_controller.dart';
import 'app/controllers/review_controller.dart';
import 'app/controllers/search_controller.dart';
import 'app/core/localization/app_translations.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

/// ---------------------------------------------------------------------------
/// LankaSeva — application entry point.
///
/// Bootstraps the controller layer (GetX, permanent instances) BEFORE the
/// first frame so persisted preferences (language, district, theme, session,
/// reviews) are available immediately, then launches the GetMaterialApp with
/// the design-system themes and the trilingual translation map.
/// ---------------------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Controller registration (single source of truth for all state) ----
  final app = Get.put(AppController(), permanent: true);
  final auth = Get.put(AuthController(), permanent: true);
  Get.put(ReviewController(), permanent: true);
  Get.put(LocationController(), permanent: true);
  final geocoder = Get.put(GeocodingController(), permanent: true);
  Get.put(DirectoryController(), permanent: true);
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

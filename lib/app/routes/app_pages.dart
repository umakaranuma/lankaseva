import 'package:get/get.dart';

import '../ui/screens/about_screen.dart';
import '../ui/screens/category_list_screen.dart';
import '../ui/screens/district_screen.dart';
import '../ui/screens/emergency_screen.dart';
import '../ui/screens/language_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/main_shell.dart';
import '../ui/screens/my_reviews_screen.dart';
import '../ui/screens/notifications_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/service_detail_screen.dart';
import '../ui/screens/service_map_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/write_review_screen.dart';

/// ---------------------------------------------------------------------------
/// Route table — mirrors the navigation structure in spec section 6.
/// Screens always navigate by named route (never by widget) so the flow
/// stays declarative and testable.
/// ---------------------------------------------------------------------------
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const language = '/language';
  static const districtSelect = '/district';
  static const main = '/main'; // Bottom-tab shell (Home/Search/Map/Reviews/Profile)
  static const emergency = '/emergency';
  static const categoryList = '/category';
  static const serviceDetail = '/service'; // arguments: Service
  static const serviceMap = '/service-map'; // arguments: Service (route view)
  static const writeReview = '/write-review'; // arguments: Service
  static const login = '/login';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const myReviews = '/my-reviews';
  static const about = '/about';
}

/// GetX page bindings for every route.
class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: Routes.language, page: () => const LanguageScreen()),
    GetPage(name: Routes.districtSelect, page: () => const DistrictScreen()),
    GetPage(name: Routes.main, page: () => const MainShell()),
    GetPage(name: Routes.emergency, page: () => const EmergencyScreen()),
    GetPage(name: Routes.categoryList, page: () => const CategoryListScreen()),
    GetPage(name: Routes.serviceDetail, page: () => const ServiceDetailScreen()),
    GetPage(name: Routes.serviceMap, page: () => const ServiceMapScreen()),
    GetPage(name: Routes.writeReview, page: () => const WriteReviewScreen()),
    GetPage(name: Routes.login, page: () => const LoginScreen()),
    GetPage(name: Routes.settings, page: () => const SettingsScreen()),
    GetPage(
        name: Routes.notifications, page: () => const NotificationsScreen()),
    GetPage(name: Routes.myReviews, page: () => const MyReviewsScreen()),
    GetPage(name: Routes.about, page: () => const AboutScreen()),
  ];
}

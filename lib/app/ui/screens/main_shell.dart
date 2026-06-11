import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'reviews_screen.dart';
import 'search_screen.dart';

/// ---------------------------------------------------------------------------
/// MainShell — bottom-tab scaffold hosting the five primary tabs
/// (spec 4.5: Home · Search · Map · Reviews · Profile). Tab index lives in
/// AppController so other screens can switch tabs programmatically.
/// ---------------------------------------------------------------------------
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    const tabs = [
      HomeScreen(),
      SearchScreen(),
      MapScreen(),
      ReviewsScreen(),
      ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          // IndexedStack keeps each tab's scroll position alive.
          body: IndexedStack(index: app.currentTab.value, children: tabs),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: app.currentTab.value,
            onTap: app.changeTab,
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: 'tab_home'.tr),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.search), label: 'tab_search'.tr),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.map_outlined),
                  activeIcon: const Icon(Icons.map),
                  label: 'tab_map'.tr),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.star_outline),
                  activeIcon: const Icon(Icons.star),
                  label: 'tab_reviews'.tr),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: 'tab_profile'.tr),
            ],
          ),
        ));
  }
}

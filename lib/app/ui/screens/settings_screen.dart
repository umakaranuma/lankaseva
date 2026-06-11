import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/search_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// SettingsScreen — app-wide preferences (spec 4.15): appearance
/// (theme/language), location, notification toggles, data & privacy
/// actions, and about links. Every action delegates to a controller.
/// ---------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Destructive account deletion behind a confirmation dialog (spec 4.15).
  void _confirmDeleteAccount(AuthController auth) {
    Get.dialog(AlertDialog(
      title: Text('delete_account'.tr),
      content: Text('delete_account_confirm'.tr),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            auth.deleteAccount();
            Get.back();
          },
          child: Text('delete'.tr),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final auth = Get.find<AuthController>();
    final search = Get.find<ServiceSearchController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(AppDimens.space4),
            children: [
              // ---- Appearance ----
              SectionLabel('appearance'.tr),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined, size: 16),
                      label: Text('theme_light'.tr)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined, size: 16),
                      label: Text('theme_dark'.tr)),
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.phone_android, size: 16),
                      label: Text('theme_system'.tr)),
                ],
                selected: {app.themeMode.value},
                onSelectionChanged: (set) => app.changeTheme(set.first),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language, color: c.primary),
                title: Text('language'.tr),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => Get.toNamed(Routes.language),
              ),
              const Divider(),

              // ---- Location ----
              SectionLabel('location'.tr),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on_outlined, color: c.primary),
                title: Text(app.district.value),
                subtitle: Text('tap_to_change'.tr,
                    style: AppTextStyles.caption
                        .copyWith(color: c.textTertiary)),
                onTap: () => Get.toNamed(Routes.districtSelect),
              ),
              const Divider(),

              // ---- Notifications (each type independently toggleable) ----
              SectionLabel('notifications'.tr),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('notif_service_updates'.tr,
                    style: AppTextStyles.body),
                value: app.notifPrefs['service_updates'] ?? false,
                onChanged: (_) => app.toggleNotif('service_updates'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('notif_emergency'.tr, style: AppTextStyles.body),
                value: app.notifPrefs['emergency'] ?? false,
                onChanged: (_) => app.toggleNotif('emergency'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('notif_replies'.tr, style: AppTextStyles.body),
                value: app.notifPrefs['replies'] ?? false,
                onChanged: (_) => app.toggleNotif('replies'),
              ),
              const Divider(),

              // ---- Data & privacy ----
              SectionLabel('data_privacy'.tr),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, size: 20),
                title: Text('clear_search_history'.tr),
                onTap: () {
                  search.clearHistory();
                  Get.rawSnackbar(message: 'cleared'.tr);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.favorite_border, size: 20),
                title: Text('clear_saved'.tr),
                onTap: app.clearSavedServices,
              ),
              if (auth.isLoggedIn)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.delete_forever, size: 20, color: c.emergency),
                  title: Text('delete_account'.tr,
                      style: TextStyle(color: c.emergency)),
                  onTap: () => _confirmDeleteAccount(auth),
                ),
              const Divider(),

              // ---- About ----
              SectionLabel('about'.tr),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, size: 20),
                title: Text('about'.tr),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => Get.toNamed(Routes.about),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_outline, size: 20),
                title: Text('rate_app'.tr),
                onTap: () => app.openUrl(
                    'https://play.google.com/store/apps/details?id=com.example.lankaseva'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bug_report_outlined, size: 20),
                title: Text('report_bug'.tr),
                onTap: () => app.openUrl('mailto:hello@lankseva.lk'),
              ),
            ],
          )),
    );
  }
}

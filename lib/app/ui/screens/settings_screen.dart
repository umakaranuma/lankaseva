import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/search_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// SettingsScreen — combined account + preferences hub (replaces the old
/// separate Profile tab for a simpler, friendlier bottom navigation).
/// Top-to-bottom: profile card (editable display name / login prompt),
/// my reviews, saved services, appearance, location, notification toggles,
/// data & privacy, about. Every action delegates to a controller.
/// ---------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Opens a one-field dialog to edit the public display name.
  void _editName(AuthController auth) {
    final controller =
        TextEditingController(text: auth.user.value?.displayName);
    Get.dialog(AlertDialog(
      title: Text('display_name'.tr),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        FilledButton(
          onPressed: () {
            auth.updateDisplayName(controller.text);
            Get.back();
          },
          child: Text('save'.tr),
        ),
      ],
    ));
  }

  /// Opens the change/remove profile-photo action sheet. Picking and
  /// storing the image is handled entirely by AuthController.
  void _changePhoto(AuthController auth) {
    final c = AppColors.of(Get.context!);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.space4),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(Icons.photo_library_outlined, color: c.primary),
            title: Text('change_photo'.tr),
            onTap: () {
              Get.back();
              auth.pickAvatar();
            },
          ),
          if (auth.user.value?.avatarPath != null)
            ListTile(
              leading: Icon(Icons.delete_outline, color: c.emergency),
              title: Text('remove_photo'.tr,
                  style: TextStyle(color: c.emergency)),
              onTap: () {
                Get.back();
                auth.removeAvatar();
              },
            ),
        ]),
      ),
    );
  }

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
    final reviews = Get.find<ReviewController>();
    final search = Get.find<ServiceSearchController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Obx(() {
        final user = auth.user.value;
        final myReviews = reviews.myReviews();
        final saved = app.savedServices;

        return ListView(
          padding: const EdgeInsets.all(AppDimens.space4),
          children: [
            // =========================================================
            // Profile section (merged from the old Profile tab)
            // =========================================================
            SectionLabel('profile'.tr),
            if (user == null)
              // Signed-out: friendly login card.
              Container(
                padding: const EdgeInsets.all(AppDimens.space4),
                decoration: BoxDecoration(
                  color: c.bgCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: c.borderLight),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: c.primaryLight, shape: BoxShape.circle),
                    child:
                        Icon(Icons.person_outline, color: c.primary, size: 26),
                  ),
                  const SizedBox(width: AppDimens.space3),
                  Expanded(
                    child: Text('login_required'.tr,
                        style:
                            AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
                  ),
                  FilledButton(
                      onPressed: () => Get.toNamed(Routes.login),
                      child: Text('log_in'.tr)),
                ]),
              )
            else ...[
              // Account card: photo avatar (tap to change), name + edit.
              Container(
                padding: const EdgeInsets.all(AppDimens.space4),
                decoration: BoxDecoration(
                  color: c.bgCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: c.borderLight),
                ),
                child: Row(children: [
                  // Avatar with a camera badge — tapping opens the
                  // change/remove photo sheet (AuthController handles IO).
                  GestureDetector(
                    onTap: () => _changePhoto(auth),
                    child: Stack(children: [
                      UserAvatar(
                          imagePath: user.avatarPath,
                          initials: user.initials,
                          size: 56),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: c.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: AppDimens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName,
                            style: AppTextStyles.heading2
                                .copyWith(color: c.textPrimary)),
                        Text(
                            'member_since'.trParams({
                              'date':
                                  '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}'
                            }),
                            style: AppTextStyles.caption
                                .copyWith(color: c.textTertiary)),
                      ],
                    ),
                  ),
                  IconButton(
                      icon:
                          Icon(Icons.edit_outlined, size: 20, color: c.primary),
                      tooltip: 'edit'.tr,
                      onPressed: () => _editName(auth)),
                ]),
              ),
              const SizedBox(height: AppDimens.space2),

              // My Reviews — opens the dedicated screen with a count badge.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.rate_review_outlined, color: c.primary),
                title: Text('my_reviews'.tr),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (myReviews.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Text('${myReviews.length}',
                            style: AppTextStyles.label
                                .copyWith(color: c.primary)),
                      ),
                    const SizedBox(width: AppDimens.space1),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
                onTap: () => Get.toNamed(Routes.myReviews),
              ),
            ],

            // Saved services (works logged in or out — device-level).
            const SizedBox(height: AppDimens.space2),
            SectionLabel('saved_services'.tr),
            if (saved.isEmpty)
              Text('no_saved'.tr,
                  style: AppTextStyles.bodySm.copyWith(color: c.textTertiary))
            else
              for (final s in saved) ServiceCard(service: s),
            const Divider(height: AppDimens.space6),

            // =========================================================
            // Preferences
            // =========================================================
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

            SectionLabel('location'.tr),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined, color: c.primary),
              title: Text(app.district.value),
              subtitle: Text('tap_to_change'.tr,
                  style: AppTextStyles.caption.copyWith(color: c.textTertiary)),
              onTap: () => Get.toNamed(Routes.districtSelect),
            ),
            const Divider(),

            // Notification toggles + link to the notification centre.
            SectionLabel('notifications'.tr),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_none, color: c.primary),
              title: Text('notifications'.tr),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Get.toNamed(Routes.notifications),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title:
                  Text('notif_service_updates'.tr, style: AppTextStyles.body),
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

            // Log out at the very bottom (emergency text colour).
            if (auth.isLoggedIn) ...[
              const SizedBox(height: AppDimens.space4),
              TextButton(
                onPressed: auth.logout,
                child: Text('log_out'.tr,
                    style: AppTextStyles.body.copyWith(color: c.emergency)),
              ),
            ],
            const SizedBox(height: AppDimens.space6),
          ],
        );
      }),
    );
  }
}

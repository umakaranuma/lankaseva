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
import '../widgets/app_sheets.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// SettingsScreen — combined account + preferences hub.
///
/// Redesigned with grouped section cards (rounded surfaces, inset
/// dividers between rows, uppercase section labels, generous spacing):
///   1. Account header card — photo avatar, name, member-since, edit
///   2. My stuff — My Reviews / Saved Services (count badges → sub-screens)
///   3. Appearance — theme segmented control + language
///   4. Location — district
///   5. Notifications — centre link + per-type toggles
///   6. Data & Privacy — clear actions, delete account
///   7. About — info, rate, report
///   8. Log out — full-width button at the bottom
/// Every action delegates to a controller; this file is pure UI.
/// ---------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // -------------------------------------------------------------------
  // Bottom-sheet helpers (no popups anywhere in the app)
  // -------------------------------------------------------------------

  /// Change/remove profile-photo actions as a bottom sheet.
  void _changePhoto(AuthController auth) {
    showActionsSheet([
      SheetAction(
        icon: Icons.photo_library_outlined,
        label: 'change_photo'.tr,
        onTap: auth.pickAvatar,
      ),
      if (auth.user.value?.avatarPath != null)
        SheetAction(
          icon: Icons.delete_outline,
          label: 'remove_photo'.tr,
          destructive: true,
          onTap: auth.removeAvatar,
        ),
    ]);
  }

  /// Account deletion behind a destructive confirmation sheet.
  Future<void> _confirmDeleteAccount(AuthController auth) async {
    final ok = await showConfirmSheet(
      title: 'delete_account'.tr,
      message: 'delete_account_confirm'.tr,
      confirmLabel: 'delete'.tr,
      icon: Icons.delete_forever_outlined,
      destructive: true,
    );
    if (ok) auth.deleteAccount();
  }

  /// Logout confirmation sheet — avoids accidental sign-outs.
  Future<void> _confirmLogout(AuthController auth) async {
    final ok = await showConfirmSheet(
      title: 'log_out'.tr,
      icon: Icons.logout,
      destructive: true,
    );
    if (ok) auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final auth = Get.find<AuthController>();
    final reviews = Get.find<ReviewController>();
    final search = Get.find<ServiceSearchController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/app_icon.png', height: 32, width: 32),
            const SizedBox(width: AppDimens.space3),
            Text('settings'.tr),
          ],
        ),
      ),
      body: Obx(() {
        final user = auth.user.value;
        final myReviewCount = reviews.myReviews().length;
        final savedCount = app.savedServiceIds.length;

        return ListView(
          padding: const EdgeInsets.all(AppDimens.space4),
          children: [
            // =========================================================
            // 1. Account header card
            // =========================================================
            if (user == null)
              _GroupCard(children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.space4),
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: c.primaryLight, shape: BoxShape.circle),
                      child: Icon(Icons.person_outline,
                          color: c.primary, size: 28),
                    ),
                    const SizedBox(width: AppDimens.space3),
                    Expanded(
                      child: Text('login_required'.tr,
                          style: AppTextStyles.bodySm
                              .copyWith(color: c.textSecondary)),
                    ),
                    FilledButton(
                        onPressed: () => Get.toNamed(Routes.login),
                        child: Text('log_in'.tr)),
                  ]),
                ),
              ])
            else
              _GroupCard(children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.space4),
                  child: Row(children: [
                    // Avatar with camera badge → photo sheet.
                    GestureDetector(
                      onTap: () => _changePhoto(auth),
                      child: Stack(children: [
                        UserAvatar(
                            imagePath: user.avatarPath,
                            initials: user.initials,
                            size: 60),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: c.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.bgCard, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 11, color: Colors.white),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: AppDimens.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName,
                              style: AppTextStyles.heading2
                                  .copyWith(color: c.textPrimary)),
                          const SizedBox(height: 2),
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
                    // Opens the full Edit Profile page (photo + name).
                    IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 20, color: c.primary),
                        tooltip: 'edit_profile'.tr,
                        onPressed: () => Get.toNamed(Routes.editProfile)),
                  ]),
                ),
              ]),
            const SizedBox(height: AppDimens.space5),

            // =========================================================
            // 2. My stuff — reviews + saved services sub-screens
            // =========================================================
            SectionLabel('profile'.tr),
            _GroupCard(children: [
              if (user != null)
                _SettingsRow(
                  icon: Icons.rate_review_outlined,
                  iconColor: c.primary,
                  title: 'my_reviews'.tr,
                  badge: myReviewCount > 0 ? '$myReviewCount' : null,
                  onTap: () => Get.toNamed(Routes.myReviews),
                ),
              _SettingsRow(
                icon: Icons.favorite_border,
                iconColor: c.emergency,
                title: 'saved_services'.tr,
                badge: savedCount > 0 ? '$savedCount' : null,
                onTap: () => Get.toNamed(Routes.savedServices),
              ),
            ]),
            const SizedBox(height: AppDimens.space5),

            // =========================================================
            // 3. Appearance
            // =========================================================
            SectionLabel('appearance'.tr),
            _GroupCard(children: [
              Padding(
                padding: const EdgeInsets.all(AppDimens.space3),
                child: SegmentedButton<ThemeMode>(
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
              ),
              _SettingsRow(
                icon: Icons.language,
                iconColor: c.info,
                title: 'language'.tr,
                onTap: () => Get.toNamed(Routes.language),
              ),
            ]),
            const SizedBox(height: AppDimens.space5),

            // =========================================================
            // 4. Location
            // =========================================================
            SectionLabel('location'.tr),
            _GroupCard(children: [
              _SettingsRow(
                icon: Icons.location_on_outlined,
                iconColor: c.success,
                title: app.district.value,
                subtitle: 'tap_to_change'.tr,
                onTap: () => Get.toNamed(Routes.districtSelect),
              ),
            ]),
            const SizedBox(height: AppDimens.space5),

            // =========================================================
            // 5. Notifications
            // =========================================================
            SectionLabel('notifications'.tr),
            _GroupCard(children: [
              _SettingsRow(
                icon: Icons.notifications_none,
                iconColor: c.warning,
                title: 'notifications'.tr,
                onTap: () => Get.toNamed(Routes.notifications),
              ),
              _ToggleRow(
                icon: Icons.update,
                iconColor: c.info,
                title: 'notif_service_updates'.tr,
                subtitle: 'notif_service_updates_sub'.tr,
                value: app.notifPrefs['service_updates'] ?? false,
                onChanged: (_) => app.toggleNotif('service_updates'),
              ),
              _ToggleRow(
                icon: Icons.warning_amber_outlined,
                iconColor: c.emergency,
                title: 'notif_emergency'.tr,
                subtitle: 'notif_emergency_sub'.tr,
                value: app.notifPrefs['emergency'] ?? false,
                onChanged: (_) => app.toggleNotif('emergency'),
              ),
              _ToggleRow(
                icon: Icons.thumb_up_outlined,
                iconColor: c.star,
                title: 'notif_replies'.tr,
                subtitle: 'notif_replies_sub'.tr,
                value: app.notifPrefs['replies'] ?? false,
                onChanged: (_) => app.toggleNotif('replies'),
              ),
            ]),
            const SizedBox(height: AppDimens.space5),

            // =========================================================
            // 6. Data & Privacy
            // =========================================================
            SectionLabel('data_privacy'.tr),
            _GroupCard(children: [
              _SettingsRow(
                icon: Icons.history,
                iconColor: c.textSecondary,
                title: 'clear_search_history'.tr,
                showChevron: false,
                onTap: () {
                  search.clearHistory();
                  Get.rawSnackbar(message: 'cleared'.tr);
                },
              ),
              _SettingsRow(
                icon: Icons.heart_broken_outlined,
                iconColor: c.textSecondary,
                title: 'clear_saved'.tr,
                showChevron: false,
                onTap: app.clearSavedServices,
              ),
              if (auth.isLoggedIn)
                _SettingsRow(
                  icon: Icons.delete_forever_outlined,
                  iconColor: c.emergency,
                  title: 'delete_account'.tr,
                  titleColor: c.emergency,
                  showChevron: false,
                  onTap: () => _confirmDeleteAccount(auth),
                ),
            ]),
            const SizedBox(height: AppDimens.space5),

            // =========================================================
            // 7. About
            // =========================================================
            SectionLabel('about'.tr),
            _GroupCard(children: [
              _SettingsRow(
                icon: Icons.info_outline,
                iconColor: c.info,
                title: 'about'.tr,
                onTap: () => Get.toNamed(Routes.about),
              ),
              _SettingsRow(
                icon: Icons.star_outline,
                iconColor: c.star,
                title: 'rate_app'.tr,
                showChevron: false,
                onTap: () => app.openUrl(
                    'https://play.google.com/store/apps/details?id=com.example.lankaseva'),
              ),
              _SettingsRow(
                icon: Icons.bug_report_outlined,
                iconColor: c.emergency,
                title: 'report_bug'.tr,
                onTap: () => Get.toNamed(Routes.reportBug),
              ),
            ]),

            // =========================================================
            // 8. Log out — proper full-width button
            // =========================================================
            if (auth.isLoggedIn) ...[
              const SizedBox(height: AppDimens.space6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.emergency,
                  side: BorderSide(color: c.emergency.withValues(alpha: 0.5)),
                  minimumSize:
                      const Size.fromHeight(AppDimens.minTouchTarget + 4),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusMd)),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: Text('log_out'.tr),
                onPressed: () => _confirmLogout(auth),
              ),
            ],
            const SizedBox(height: AppDimens.space6),
          ],
        );
      }),
    );
  }
}

/// Rounded grouped card hosting settings rows, with thin inset dividers
/// drawn automatically between children (iOS-settings style).
class _GroupCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.borderLight),
      ),
      child: Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            Divider(
                height: 1,
                indent: 52, // Inset past the leading icon for a smooth look
                color: c.borderLight),
        ],
      ]),
    );
  }
}

/// One tappable settings row: tinted leading icon, title, optional
/// subtitle / count badge / chevron.
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? titleColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.badge,
    this.titleColor,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space3, vertical: AppDimens.space3),
        child: Row(children: [
          // Tinted icon chip for a richer, scannable look.
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm + 2),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppDimens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(color: titleColor ?? c.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: AppTextStyles.caption
                          .copyWith(color: c.textTertiary)),
              ],
            ),
          ),
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(right: AppDimens.space1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: c.primaryLight,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Text(badge!,
                  style: AppTextStyles.label.copyWith(color: c.primary)),
            ),
          if (showChevron)
            Icon(Icons.chevron_right, size: 18, color: c.textTertiary),
        ]),
      ),
    );
  }
}

/// One switch row inside a group card. Matches _SettingsRow metrics:
/// tinted icon chip + title + explanatory subtitle, switch on the right,
/// and the entire row is tappable (not just the small switch) for a much
/// friendlier touch target.
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      // Whole-row tap flips the toggle (44pt+ target, spec 5.10).
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space3, vertical: AppDimens.space2),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm + 2),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppDimens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body.copyWith(color: c.textPrimary)),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: c.textTertiary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ]),
      ),
    );
  }
}

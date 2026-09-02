import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/review_controller.dart';
import '../../controllers/search_controller.dart';
import '../../data/models/user_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';
import '../widgets/app_sheets.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// SettingsScreen — account + preferences hub.
///
/// The screen scaffold is a plain (non-reactive) ListView; only the small
/// pieces that actually depend on state (the account card, the theme choice,
/// the notification switches, the count badges) are wrapped in their own
/// `Obx`. Every section stays visible whether or not the user is signed in.
/// ---------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // -------- bottom-sheet helpers (no popups in the app) --------

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
        flexibleSpace: Container(
            decoration: BoxDecoration(gradient: c.headerGradient)),
        title: Text('settings'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.space4),
        children: [
          // 1 ─ Account / sign-in  (read .value INSIDE the Obx closure)
          Obx(() => _AccountCard(
                user: auth.user.value,
                onSignIn: () => Get.toNamed(Routes.login),
                onPhoto: () => _changePhoto(auth),
                onEdit: () => Get.toNamed(Routes.editProfile),
              )),
          const SizedBox(height: AppDimens.space5),

          // 2 ─ Your activity
          SectionLabel('profile'.tr),
          _GroupCard(children: [
            Obx(() {
              final loggedIn = auth.user.value != null;
              final myReviewCount = reviews.myReviews().length;
              return _SettingsRow(
                icon: Icons.rate_review_outlined,
                iconColor: c.primary,
                title: 'my_reviews'.tr,
                subtitle: loggedIn ? null : 'login_required'.tr,
                badge:
                    (loggedIn && myReviewCount > 0) ? '$myReviewCount' : null,
                onTap: () => loggedIn
                    ? Get.toNamed(Routes.myReviews)
                    : Get.toNamed(Routes.login),
              );
            }),
            Obx(() {
              final savedCount = app.savedServiceIds.length;
              return _SettingsRow(
                icon: Icons.favorite_border,
                iconColor: c.primary,
                title: 'saved_services'.tr,
                badge: savedCount > 0 ? '$savedCount' : null,
                onTap: () => Get.toNamed(Routes.savedServices),
              );
            }),
          ]),
          const SizedBox(height: AppDimens.space5),

          // 3 ─ Appearance
          SectionLabel('appearance'.tr),
          _GroupCard(children: [
            Obx(() => _ThemeChoiceRow(
                  selected: app.themeMode.value,
                  onChanged: app.changeTheme,
                )),
            _SettingsRow(
              icon: Icons.language,
              iconColor: c.primary,
              title: 'language'.tr,
              onTap: () => Get.toNamed(Routes.language),
            ),
          ]),
          const SizedBox(height: AppDimens.space5),

          // 4 ─ Location
          SectionLabel('location'.tr),
          _GroupCard(children: [
            Obx(() => _SettingsRow(
                  icon: Icons.location_on_outlined,
                  iconColor: c.primary,
                  title: app.district.value,
                  subtitle: 'tap_to_change'.tr,
                  onTap: () => Get.toNamed(Routes.districtSelect),
                )),
          ]),
          const SizedBox(height: AppDimens.space5),

          // 5 ─ Notifications
          SectionLabel('notifications'.tr),
          _GroupCard(children: [
            _SettingsRow(
              icon: Icons.notifications_none,
              iconColor: c.primary,
              title: 'notifications'.tr,
              onTap: () => Get.toNamed(Routes.notifications),
            ),
            Obx(() => _ToggleRow(
                  icon: Icons.update,
                  iconColor: c.primary,
                  title: 'notif_service_updates'.tr,
                  subtitle: 'notif_service_updates_sub'.tr,
                  value: app.notifPrefs['service_updates'] ?? false,
                  onChanged: (_) => app.toggleNotif('service_updates'),
                )),
            Obx(() => _ToggleRow(
                  icon: Icons.warning_amber_outlined,
                  iconColor: c.emergency,
                  title: 'notif_emergency'.tr,
                  subtitle: 'notif_emergency_sub'.tr,
                  value: app.notifPrefs['emergency'] ?? false,
                  onChanged: (_) => app.toggleNotif('emergency'),
                )),
            Obx(() => _ToggleRow(
                  icon: Icons.thumb_up_outlined,
                  iconColor: c.primary,
                  title: 'notif_replies'.tr,
                  subtitle: 'notif_replies_sub'.tr,
                  value: app.notifPrefs['replies'] ?? false,
                  onChanged: (_) => app.toggleNotif('replies'),
                )),
          ]),
          const SizedBox(height: AppDimens.space5),

          // 6 ─ Data & privacy
          SectionLabel('data_privacy'.tr),
          _GroupCard(children: [
            _SettingsRow(
              icon: Icons.history,
              iconColor: c.textSecondary,
              title: 'clear_search_history'.tr,
              showChevron: false,
              onTap: () {
                search.clearHistory();
                AppToast.show('cleared'.tr);
              },
            ),
            _SettingsRow(
              icon: Icons.heart_broken_outlined,
              iconColor: c.textSecondary,
              title: 'clear_saved'.tr,
              showChevron: false,
              onTap: app.clearSavedServices,
            ),
            Obx(() => auth.user.value == null
                ? const SizedBox.shrink()
                : _SettingsRow(
                    icon: Icons.delete_forever_outlined,
                    iconColor: c.emergency,
                    title: 'delete_account'.tr,
                    titleColor: c.emergency,
                    showChevron: false,
                    onTap: () => _confirmDeleteAccount(auth),
                  )),
          ]),
          const SizedBox(height: AppDimens.space5),

          // 7 ─ About
          SectionLabel('about'.tr),
          _GroupCard(children: [
            _SettingsRow(
              icon: Icons.info_outline,
              iconColor: c.primary,
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

          // 8 ─ Sign out (only when signed in)
          Obx(() => auth.user.value == null
              ? const SizedBox(height: AppDimens.space6)
              : Padding(
                  padding: const EdgeInsets.only(top: AppDimens.space6),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.emergency,
                      side:
                          BorderSide(color: c.emergency.withValues(alpha: 0.5)),
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
                )),
          const SizedBox(height: AppDimens.space6),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Account card — signed-out hero  /  signed-in profile
// ===========================================================================

class _AccountCard extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onSignIn;
  final VoidCallback onPhoto;
  final VoidCallback onEdit;
  const _AccountCard({
    required this.user,
    required this.onSignIn,
    required this.onPhoto,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final user = this.user;

    // ---- Signed out: prominent invitation ----
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.space4),
        decoration: BoxDecoration(
          gradient: c.headerGradient,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          boxShadow: c.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.onEmphasis.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(Icons.person_outline,
                    color: c.onEmphasis, size: 26),
              ),
              const SizedBox(width: AppDimens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('login_title'.tr,
                        style: AppTextStyles.heading2
                            .copyWith(color: c.onEmphasis)),
                    const SizedBox(height: 2),
                    Text('login_required'.tr,
                        style: AppTextStyles.caption.copyWith(
                            color: c.onEmphasis.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: AppDimens.space4),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: c.onEmphasis,
                foregroundColor: c.primary,
                minimumSize:
                    const Size.fromHeight(AppDimens.minTouchTarget + 2),
              ),
              onPressed: onSignIn,
              child: Text('log_in'.tr),
            ),
          ],
        ),
      );
    }

    // ---- Signed in: profile summary ----
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.borderLight),
        boxShadow: c.shadowSm,
      ),
      padding: const EdgeInsets.all(AppDimens.space4),
      child: Row(children: [
        GestureDetector(
          onTap: onPhoto,
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
                child: Icon(Icons.camera_alt,
                    size: 11, color: c.onEmphasis),
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
                  style:
                      AppTextStyles.heading2.copyWith(color: c.textPrimary)),
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
        IconButton(
          icon: Icon(Icons.edit_outlined, size: 20, color: c.primary),
          tooltip: 'edit_profile'.tr,
          onPressed: onEdit,
        ),
      ]),
    );
  }
}

// ===========================================================================
//  Theme choice — three tappable cards (no SegmentedButton)
// ===========================================================================

class _ThemeChoiceRow extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemeChoiceRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const opts = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.light_mode_outlined, 'theme_light'),
      (ThemeMode.dark, Icons.dark_mode_outlined, 'theme_dark'),
      (ThemeMode.system, Icons.phone_android, 'theme_system'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space3, vertical: AppDimens.space2),
      child: Row(
        children: [
          for (final (mode, icon, key) in opts)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(mode),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimens.space3),
                  decoration: BoxDecoration(
                    color: selected == mode
                        ? c.primaryLight
                        : c.bgSecondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color:
                          selected == mode ? c.primary : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(icon,
                          size: 20,
                          color: selected == mode
                              ? c.primary
                              : c.textSecondary),
                      const SizedBox(height: 4),
                      Text(key.tr,
                          style: AppTextStyles.label.copyWith(
                              color: selected == mode
                                  ? c.primary
                                  : c.textSecondary,
                              fontWeight: selected == mode
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Shared row widgets
// ===========================================================================

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
        boxShadow: c.shadowSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, indent: 56, color: c.borderLight),
          ],
        ],
      ),
    );
  }
}

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
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
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
                  style: AppTextStyles.label.copyWith(
                      color: c.primary, fontWeight: FontWeight.w700)),
            ),
          if (showChevron)
            Icon(Icons.chevron_right, size: 18, color: c.textTertiary),
        ]),
      ),
    );
  }
}

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
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space3, vertical: AppDimens.space2),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
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
                    style:
                        AppTextStyles.body.copyWith(color: c.textPrimary)),
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

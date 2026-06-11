import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// HomeScreen — primary entry point (spec 4.5).
/// Sections top-to-bottom: app bar with language pills, search bar,
/// district chip, emergency banner + quick-dial grid, category grid,
/// "Near you" list with one ad strip.
/// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final directory = Get.find<DirectoryController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppInfo.appName,
            style: AppTextStyles.heading2.copyWith(color: c.primaryText)),
        actions: [
          // Inline language switcher pills (spec 4.5).
          const _LanguagePills(),
          // Notification bell with a live unread badge.
          Obx(() {
            final unread =
                Get.find<NotificationController>().unreadCount;
            return IconButton(
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: const Icon(Icons.notifications_none),
              ),
              onPressed: () => Get.toNamed(Routes.notifications),
            );
          }),
        ],
      ),
      body: Obx(() {
        final lang = app.language.value;
        final nearby = directory.nearbyServices();
        return ListView(
          padding: const EdgeInsets.all(AppDimens.space4),
          children: [
            // ---- Search bar (navigates to the Search tab) ----
            InkWell(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              onTap: () => app.changeTab(1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.space3, vertical: AppDimens.space3),
                decoration: BoxDecoration(
                  color: c.bgInput,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: c.borderLight),
                ),
                child: Row(children: [
                  Icon(Icons.search, size: 20, color: c.textTertiary),
                  const SizedBox(width: AppDimens.space2),
                  Expanded(
                      child: Text('search_hint'.tr,
                          style: AppTextStyles.body
                              .copyWith(color: c.textTertiary))),
                  Icon(Icons.tune, size: 20, color: c.textTertiary),
                ]),
              ),
            ),
            const SizedBox(height: AppDimens.space3),

            // ---- District chip ----
            const DistrictChip(),
            const SizedBox(height: AppDimens.space5),

            // ---- Emergency banner ----
            InkWell(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              onTap: () => Get.toNamed(Routes.emergency),
              child: Container(
                padding: const EdgeInsets.all(AppDimens.space4),
                decoration: BoxDecoration(
                  color: c.emergency,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                child: Row(children: [
                  const Icon(Icons.emergency_outlined,
                      color: Colors.white, size: 28),
                  const SizedBox(width: AppDimens.space3),
                  Expanded(
                    child: Text('emergency_contacts'.tr,
                        style: AppTextStyles.heading2
                            .copyWith(color: Colors.white)),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ]),
              ),
            ),
            const SizedBox(height: AppDimens.space2),

            // ---- 2×2 quick-dial grid (Police/Ambulance/Fire/Disaster) ----
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimens.space2,
              crossAxisSpacing: AppDimens.space2,
              childAspectRatio: 2.6,
              children: [
                for (final e in kQuickDialContacts)
                  InkWell(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    // One-tap call with confirm dialog (controller handles it).
                    onTap: () => app.callNumber(e.number),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space3),
                      decoration: BoxDecoration(
                        color: e.color,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Row(children: [
                        Icon(e.icon, color: Colors.white, size: 20),
                        const SizedBox(width: AppDimens.space2),
                        Expanded(
                          child: Text(e.nameKey.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: Colors.white)),
                        ),
                        Text(e.number,
                            style: AppTextStyles.heading2
                                .copyWith(color: Colors.white)),
                      ]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.space5),

            // ---- Category grid (4 columns, 8 + More) ----
            SectionLabel('browse_by_category'.tr),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimens.space3,
              childAspectRatio: 0.82,
              children: [
                for (final meta in kCategories)
                  _CategoryTile(
                    icon: meta.icon,
                    color: meta.color,
                    label: meta.name(lang),
                    onTap: () {
                      directory.openCategory(meta.id);
                      Get.toNamed(Routes.categoryList);
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.space5),

            // ---- Near you list, with a single ad strip inserted ----
            SectionLabel('${'near_you'.tr} — ${app.district.value}'),
            for (var i = 0; i < nearby.length; i++) ...[
              ServiceCard(service: nearby[i]),
              if (i == 2) const AdStrip(), // 1 contextual ad max (spec 5.7)
            ],
            Center(
              child: TextButton(
                onPressed: () => app.changeTab(2), // Map/list shows all
                child: Text('see_all'.tr),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Compact language pill row inside the app bar (සිංහල · EN · தமிழ்).
class _LanguagePills extends StatelessWidget {
  const _LanguagePills();

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    const langs = [('si', 'සිං'), ('en', 'EN'), ('ta', 'த')];
    return Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (code, label) in langs)
              GestureDetector(
                onTap: () => app.changeLanguage(code),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: app.language.value == code
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(label,
                      style: AppTextStyles.label
                          .copyWith(color: Colors.white)),
                ),
              ),
          ],
        ));
  }
}

/// One coloured icon circle + label tile in the category grid.
class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppDimens.space1),
          Text(label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.micro.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}

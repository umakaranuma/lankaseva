import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/sources/service_data_source.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// ProfileScreen — account details, review history, saved services
/// (spec 4.14). Shows a login prompt when signed out. Account/data actions
/// are all delegated to AuthController / AppController / ReviewController.
/// ---------------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final auth = Get.find<AuthController>();
    final reviews = Get.find<ReviewController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Get.toNamed(Routes.settings)),
        ],
      ),
      body: Obx(() {
        final user = auth.user.value;
        // ---- Signed-out state: login prompt ----
        if (user == null) {
          return EmptyState(
            icon: Icons.person_outline,
            message: 'login_required'.tr,
            ctaLabel: 'log_in'.tr,
            onCta: () => Get.toNamed(Routes.login),
          );
        }
        final myReviews = reviews.myReviews();
        final saved = app.savedServices;

        return ListView(
          padding: const EdgeInsets.all(AppDimens.space4),
          children: [
            // ---- Account card ----
            Container(
              padding: const EdgeInsets.all(AppDimens.space4),
              decoration: BoxDecoration(
                color: c.bgCard,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: c.borderLight),
              ),
              child: Row(children: [
                InitialsAvatar(initials: user.initials, size: 52),
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
                    icon: Icon(Icons.edit_outlined,
                        size: 20, color: c.primary),
                    onPressed: () => _editName(auth)),
              ]),
            ),
            const SizedBox(height: AppDimens.space5),

            // ---- My Reviews ----
            SectionLabel('my_reviews'.tr),
            if (myReviews.isEmpty)
              Text('no_reviews_district'.tr,
                  style: AppTextStyles.bodySm.copyWith(color: c.textTertiary))
            else
              for (final r in myReviews)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      ServiceDataSource.byId(r.serviceId)
                              ?.name
                              .of(app.language.value) ??
                          r.serviceId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTextStyles.heading3.copyWith(color: c.textPrimary)),
                  subtitle: Row(children: [
                    StarRow(rating: r.stars.toDouble()),
                    const SizedBox(width: AppDimens.space2),
                    Text(r.relativeDate,
                        style: AppTextStyles.caption
                            .copyWith(color: c.textTertiary)),
                  ]),
                  trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 20, color: c.emergency),
                      onPressed: () => reviews.deleteReview(r.id)),
                  onTap: () {
                    final s = ServiceDataSource.byId(r.serviceId);
                    if (s != null) {
                      Get.toNamed(Routes.serviceDetail, arguments: s);
                    }
                  },
                ),
            const SizedBox(height: AppDimens.space5),

            // ---- Saved services ----
            SectionLabel('saved_services'.tr),
            if (saved.isEmpty)
              Text('no_saved'.tr,
                  style: AppTextStyles.bodySm.copyWith(color: c.textTertiary))
            else
              for (final s in saved) ServiceCard(service: s),
            const SizedBox(height: AppDimens.space5),

            // ---- District + language shortcuts ----
            SectionLabel('my_district'.tr),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined, color: c.primary),
              title: Text(app.district.value),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Get.toNamed(Routes.districtSelect),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.language, color: c.primary),
              title: Text('language'.tr),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => Get.toNamed(Routes.language),
            ),
            const SizedBox(height: AppDimens.space5),

            // ---- Log out (emergency text colour per spec 4.14) ----
            TextButton(
              onPressed: auth.logout,
              child: Text('log_out'.tr,
                  style: AppTextStyles.body.copyWith(color: c.emergency)),
            ),
          ],
        );
      }),
    );
  }
}

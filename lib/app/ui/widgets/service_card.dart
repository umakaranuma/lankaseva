import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_pages.dart';

/// ---------------------------------------------------------------------------
/// ServiceCard
/// ---------------------------------------------------------------------------
/// The standard directory card used on Home, Category List, Search and the
/// Map list (spec 4.5 / 4.7). Shows category icon, localised name, rating,
/// open/closed badge, distance — plus a one-tap call button and a bookmark
/// heart. Pure UI: every action is delegated to a controller.
/// ---------------------------------------------------------------------------
class ServiceCard extends StatelessWidget {
  final Service service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final reviews = Get.find<ReviewController>();
    final c = AppColors.of(context);
    final meta = categoryMeta(service.category);

    return Obx(() {
      final lang = app.language.value;
      final avg = reviews.averageFor(service.id);
      final count = reviews.countFor(service.id);
      final isOpen = service.hours.isOpenAt(DateTime.now());
      final saved = app.isSaved(service.id);

      return Container(
        margin: const EdgeInsets.only(bottom: AppDimens.space2),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: c.borderLight),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          // Whole card opens the Service Detail screen.
          onTap: () => Get.toNamed(Routes.serviceDetail, arguments: service),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space3),
            child: Row(
              children: [
                // Category icon in a bordered circle (minimal palette —
                // single primary accent, colour lives on the border).
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.borderMedium),
                  ),
                  child: Icon(meta.icon, color: c.primary, size: 22),
                ),
                const SizedBox(width: AppDimens.space3),
                // Name, rating and status column.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name.of(lang),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading3
                              .copyWith(color: c.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (count > 0) ...[
                            Icon(Icons.star, size: 13, color: c.star),
                            const SizedBox(width: 2),
                            Text('${avg.toStringAsFixed(1)} ($count)',
                                style: AppTextStyles.caption
                                    .copyWith(color: c.textSecondary)),
                            const SizedBox(width: AppDimens.space2),
                          ],
                          // Live open/closed badge — bordered, not filled
                          // (spec 5.3).
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isOpen ? c.success : c.emergency),
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            child: Text(isOpen ? 'open'.tr : 'closed'.tr,
                                style: AppTextStyles.label.copyWith(
                                    color:
                                        isOpen ? c.success : c.emergency)),
                          ),
                          const SizedBox(width: AppDimens.space2),
                          // Live distance: real GPS distance once a fix
                          // exists, seeded estimate before that.
                          Text(
                              '${Get.find<DirectoryController>().distanceOf(service).toStringAsFixed(1)} km',
                              style: AppTextStyles.caption
                                  .copyWith(color: c.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bookmark heart (Profile → Saved Services, spec 4.14).
                IconButton(
                  icon: Icon(saved ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: saved ? c.emergency : c.textTertiary),
                  onPressed: () => app.toggleSaved(service.id),
                ),
                // One-tap call button — bordered (minimal, no fill).
                IconButton(
                  style: IconButton.styleFrom(
                    side: BorderSide(color: c.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusMd),
                    ),
                  ),
                  icon: Icon(Icons.phone, size: 20, color: c.primary),
                  onPressed: () =>
                      app.callNumber(service.primaryPhone.number),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

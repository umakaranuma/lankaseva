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
import 'common_widgets.dart';

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
        margin: const EdgeInsets.only(bottom: AppDimens.space3),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: c.borderLight),
          boxShadow: c.shadowSm,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          // Whole card opens the Service Detail screen.
          onTap: () => Get.toNamed(Routes.serviceDetail, arguments: service),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space3),
            child: Row(
              children: [
                // Category glyph on a soft tint of its own accent colour.
                IconChip(icon: meta.icon, color: meta.color, size: 46),
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
                      Wrap(
                        spacing: AppDimens.space2,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (count > 0)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.star_rounded, size: 15, color: c.star),
                              const SizedBox(width: 2),
                              Text('${avg.toStringAsFixed(1)} ($count)',
                                  style: AppTextStyles.caption.copyWith(
                                      color: c.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ]),
                          // Live open/closed badge — soft-filled pill.
                          StatusPill(
                            label: isOpen ? 'open'.tr : 'closed'.tr,
                            color: isOpen ? c.success : c.emergency,
                            icon: isOpen
                                ? Icons.circle
                                : Icons.circle_outlined,
                          ),
                          // Live distance: real GPS distance once a fix
                          // exists, seeded estimate before that.
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.near_me_rounded,
                                size: 12, color: c.textTertiary),
                            const SizedBox(width: 2),
                            Text(
                                '${Get.find<DirectoryController>().distanceOf(service).toStringAsFixed(1)} km',
                                style: AppTextStyles.caption
                                    .copyWith(color: c.textTertiary)),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bookmark heart (Profile → Saved Services, spec 4.14).
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                      saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 20,
                      color: saved ? c.emergency : c.textTertiary),
                  onPressed: () => app.toggleSaved(service.id),
                ),
                // One-tap call button — solid primary, subtle lift.
                Container(
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    boxShadow: c.shadowSm,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.phone_rounded,
                        size: 20, color: c.primaryText),
                    onPressed: () =>
                        app.callNumber(service.primaryPhone.number),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

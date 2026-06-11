import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/sources/service_data_source.dart';
import '../../routes/app_pages.dart';
import '../widgets/app_sheets.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// MyReviewsScreen — dedicated list of the logged-in user's reviews,
/// opened from Settings → My Reviews. Each card shows the reviewed
/// service (with category icon), stars, date, the review text and the
/// experience tags, with delete and open-service actions. Deleting asks
/// for confirmation; all data operations live in ReviewController.
/// ---------------------------------------------------------------------------
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  /// Confirms before deleting a review via the destructive bottom sheet.
  Future<void> _confirmDelete(
      ReviewController reviews, String reviewId) async {
    final ok = await showConfirmSheet(
      title: 'delete'.tr,
      message: 'delete_review_confirm'.tr,
      confirmLabel: 'delete'.tr,
      icon: Icons.delete_outline,
      destructive: true,
    );
    if (ok) reviews.deleteReview(reviewId);
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final reviews = Get.find<ReviewController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('my_reviews'.tr)),
      body: Obx(() {
        // Touch the list observable so deletions rebuild this screen.
        reviews.reviews.length;
        final mine = reviews.myReviews();
        if (mine.isEmpty) {
          return EmptyState(
            icon: Icons.rate_review_outlined,
            message: 'no_my_reviews'.tr,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimens.space4),
          itemCount: mine.length,
          itemBuilder: (_, i) {
            final r = mine[i];
            final service = ServiceDataSource.byId(r.serviceId);
            final meta =
                service != null ? categoryMeta(service.category) : null;
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimens.space2),
              padding: const EdgeInsets.all(AppDimens.space3),
              decoration: BoxDecoration(
                color: c.bgCard,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: c.borderLight),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                onTap: service == null
                    ? null
                    : () =>
                        Get.toNamed(Routes.serviceDetail, arguments: service),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service header row + delete action.
                    Row(children: [
                      if (meta != null) ...[
                        Icon(meta.icon, size: 18, color: meta.color),
                        const SizedBox(width: AppDimens.space2),
                      ],
                      Expanded(
                        child: Text(
                            service?.name.of(app.language.value) ??
                                r.serviceId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading3
                                .copyWith(color: c.textPrimary)),
                      ),
                      IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 20, color: c.emergency),
                          tooltip: 'delete'.tr,
                          onPressed: () => _confirmDelete(reviews, r.id)),
                    ]),
                    // Stars + date.
                    Row(children: [
                      StarRow(rating: r.stars.toDouble()),
                      const SizedBox(width: AppDimens.space2),
                      Text(r.relativeDate,
                          style: AppTextStyles.caption
                              .copyWith(color: c.textTertiary)),
                    ]),
                    const SizedBox(height: AppDimens.space2),
                    // Review text.
                    Text(r.text,
                        style:
                            AppTextStyles.body.copyWith(color: c.textPrimary)),
                    // Experience tags.
                    if (r.positiveTags.isNotEmpty || r.negativeTags.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: AppDimens.space2),
                        child: Wrap(
                          spacing: AppDimens.space1,
                          runSpacing: AppDimens.space1,
                          children: [
                            for (final t in r.positiveTags)
                              Chip(
                                  label: Text(t.tr,
                                      style: AppTextStyles.label
                                          .copyWith(color: c.success)),
                                  backgroundColor: c.successLight,
                                  visualDensity: VisualDensity.compact,
                                  side: BorderSide.none),
                            for (final t in r.negativeTags)
                              Chip(
                                  label: Text(t.tr,
                                      style: AppTextStyles.label
                                          .copyWith(color: c.warning)),
                                  backgroundColor: c.warningLight,
                                  visualDensity: VisualDensity.compact,
                                  side: BorderSide.none),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

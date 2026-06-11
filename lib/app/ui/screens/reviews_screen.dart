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
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// ReviewsScreen — community feed of recent reviews (spec 4.11) with star
/// and district filters. Tapping a card opens the reviewed service.
/// ---------------------------------------------------------------------------
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final reviews = Get.find<ReviewController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/app_icon.png', height: 32, width: 32),
            const SizedBox(width: AppDimens.space3),
            Text('community_reviews'.tr),
          ],
        ),
      ),
      body: Obx(() {
        final lang = app.language.value;
        final fullFeed = reviews.communityFeed();
        // Paginated slice of the feed (controller owns the page cursor).
        final feed = fullFeed.take(reviews.feedVisible.value).toList();
        final hasMore = fullFeed.length > feed.length;
        return Column(
          children: [
            // Filter row: district-only toggle + 1–5 star chips.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppDimens.space3),
              child: Row(children: [
                FilterChip(
                  avatar: Icon(Icons.location_on_outlined,
                      size: 16, color: c.primary),
                  label: Text(app.district.value,
                      style: const TextStyle(fontSize: 12)),
                  selected: reviews.feedDistrictOnly.value,
                  onSelected: (_) => reviews.toggleFeedDistrictOnly(),
                ),
                const SizedBox(width: AppDimens.space2),
                for (var s = 5; s >= 1; s--)
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimens.space2),
                    child: FilterChip(
                      label: Text('$s★', style: const TextStyle(fontSize: 12)),
                      selected: reviews.feedStarFilter.value == s,
                      onSelected: (_) => reviews.setFeedStarFilter(s),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: feed.isEmpty
                  ? EmptyState(
                      icon: Icons.rate_review_outlined,
                      message: 'no_reviews_district'.tr)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space4),
                      // Extra slot hosts the "Load more" pagination button.
                      itemCount: feed.length + (hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= feed.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.space3),
                            child: OutlinedButton(
                              onPressed: reviews.loadMoreFeed,
                              child: Text('load_more'.tr),
                            ),
                          );
                        }
                        final r = feed[i];
                        final service = ServiceDataSource.byId(r.serviceId);
                        if (service == null) return const SizedBox.shrink();
                        final meta = categoryMeta(service.category);
                        return Container(
                          margin: const EdgeInsets.only(
                              bottom: AppDimens.space2),
                          padding: const EdgeInsets.all(AppDimens.space3),
                          decoration: BoxDecoration(
                            color: c.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusLg),
                            border: Border.all(color: c.borderLight),
                          ),
                          child: InkWell(
                            onTap: () => Get.toNamed(Routes.serviceDetail,
                                arguments: service),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service name + category badge.
                                Row(children: [
                                  Icon(meta.icon,
                                      size: 16, color: meta.color),
                                  const SizedBox(width: AppDimens.space1),
                                  Expanded(
                                    child: Text(service.name.of(lang),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.heading3
                                            .copyWith(color: c.textPrimary)),
                                  ),
                                ]),
                                const SizedBox(height: AppDimens.space2),
                                // Reviewer row.
                                Row(children: [
                                  InitialsAvatar(
                                      initials: r.initials, size: 26),
                                  const SizedBox(width: AppDimens.space2),
                                  Text(r.displayName,
                                      style: AppTextStyles.bodySm.copyWith(
                                          color: c.textSecondary)),
                                  const Spacer(),
                                  StarRow(rating: r.stars.toDouble()),
                                ]),
                                const SizedBox(height: AppDimens.space2),
                                // Review text, truncated to 3 lines.
                                Text(r.text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body
                                        .copyWith(color: c.textPrimary)),
                                const SizedBox(height: AppDimens.space2),
                                Row(children: [
                                  Text(r.relativeDate,
                                      style: AppTextStyles.caption
                                          .copyWith(color: c.textTertiary)),
                                  const Spacer(),
                                  // Helpful voting.
                                  TextButton.icon(
                                    icon: const Icon(Icons.thumb_up_outlined,
                                        size: 14),
                                    label: Text(
                                        '${'helpful'.tr} (${r.helpfulCount})',
                                        style:
                                            const TextStyle(fontSize: 12)),
                                    onPressed: () => reviews.markHelpful(r),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

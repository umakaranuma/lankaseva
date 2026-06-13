import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../controllers/review_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// ServiceDetailScreen — full contact info, actions, ad strip and the
/// review section for one service (spec 4.8). The Service object arrives
/// via route arguments; all behaviour is delegated to controllers.
/// ---------------------------------------------------------------------------
class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  /// Weekday labels for the opening-hours table.
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    // Restart review pagination so every detail visit shows page one.
    Get.find<ReviewController>().resetDetailReviews();
    // Controller owns the fetch + state; the screen just kicks it off.
    Get.find<DirectoryController>().openDetail(Get.arguments as Service);
  }

  /// Routes to Write Review, detouring through Login when signed out
  /// (spec 4.12 — login with return redirect).
  void _onWriteReview(Service service) {
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      Get.toNamed(Routes.writeReview, arguments: service);
    } else {
      auth.pendingRedirect = Routes.writeReview;
      auth.pendingRedirectArgs = service;
      Get.toNamed(Routes.login, arguments: service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final auth = Get.find<AuthController>();
    final directory = Get.find<DirectoryController>();
    final reviewsCtrl = Get.find<ReviewController>();
    final c = AppColors.of(context);

    return Scaffold(
      body: Obx(() {
        // Reactive: rebuilds when the controller's API refresh lands.
        final service = directory.detailService.value ?? (Get.arguments as Service);
        final meta = categoryMeta(service.category);
        final lang = app.language.value;
        final avg = reviewsCtrl.averageFor(service.id);
        final count = reviewsCtrl.countFor(service.id);
        final dist = reviewsCtrl.distributionFor(service.id);
        // Paginated review slice — grows via "See all N reviews".
        final allReviews = reviewsCtrl.reviewsFor(service.id);
        final reviews =
            allReviews.take(reviewsCtrl.detailVisible.value).toList();
        final moreCount = allReviews.length - reviews.length;
        final isOpen = service.hours.isOpenAt(DateTime.now());
        final saved = app.isSaved(service.id);
        // One review per user per service: once they've reviewed, the entry
        // is disabled with a clear label (consistent for every user).
        final alreadyReviewed =
            auth.isLoggedIn && reviewsCtrl.hasReviewed(service.id);

        return CustomScrollView(slivers: [
          // ---- Header (single app theme colour for every service) ----
          SliverAppBar(
            backgroundColor: c.primary,
            pinned: true,
            expandedHeight: 190,
            actions: [
              IconButton(
                icon: Icon(saved ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white),
                onPressed: () => app.toggleSaved(service.id),
              ),
            ],
            // Thin progress bar while GET /api/services/{id}/ is in flight.
            bottom: directory.detailRefreshing.value
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3),
                    child: LinearProgressIndicator(minHeight: 3),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.space4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        child: Icon(meta.icon, color: Colors.white),
                      ),
                      const SizedBox(height: AppDimens.space2),
                      Text(service.name.of(lang),
                          style: AppTextStyles.heading2
                              .copyWith(color: Colors.white)),
                      Text(service.department.of(lang),
                          style: AppTextStyles.bodySm.copyWith(
                              color: Colors.white.withValues(alpha: 0.75))),
                      const SizedBox(height: AppDimens.space1),
                      // District badge.
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusSm)),
                        child: Text(service.district,
                            style: AppTextStyles.label
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Stats row: rating / review count / open status ----
                  Row(children: [
                    _MetricChip(
                        icon: Icons.star,
                        iconColor: c.star,
                        label: count > 0 ? avg.toStringAsFixed(1) : '—'),
                    const SizedBox(width: AppDimens.space2),
                    _MetricChip(
                        icon: Icons.rate_review_outlined,
                        iconColor: c.info,
                        label: '$count ${'reviews'.tr}'),
                    const SizedBox(width: AppDimens.space2),
                    _MetricChip(
                        icon: Icons.access_time,
                        iconColor: isOpen ? c.success : c.emergency,
                        label: isOpen ? 'open'.tr : 'closed'.tr),
                  ]),
                  const SizedBox(height: AppDimens.space4),

                  // ---- Contact table ----
                  _SectionCard(children: [
                    // Every phone number is individually tappable to call.
                    for (final p in service.phones)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.phone, color: c.primary, size: 20),
                        title: Text(p.label.of(lang),
                            style: AppTextStyles.caption
                                .copyWith(color: c.textTertiary)),
                        subtitle: Text(p.number,
                            style: AppTextStyles.phoneNumber
                                .copyWith(color: c.primary, fontSize: 16)),
                        onTap: () => app.callNumber(p.number),
                      ),
                    // Address opens the native map (controller hand-off).
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.location_on_outlined,
                          color: c.primary, size: 20),
                      title: Text('address'.tr,
                          style: AppTextStyles.caption
                              .copyWith(color: c.textTertiary)),
                      subtitle: Text(service.address.of(lang),
                          style: AppTextStyles.bodySm
                              .copyWith(color: c.textPrimary)),
                      onTap: () => directory.openServiceMap(service),
                    ),
                    if (service.website != null)
                      ListTile(
                        dense: true,
                        leading:
                            Icon(Icons.language, color: c.primary, size: 20),
                        title: Text('website'.tr,
                            style: AppTextStyles.caption
                                .copyWith(color: c.textTertiary)),
                        subtitle: Text(service.website!,
                            style: AppTextStyles.bodySm
                                .copyWith(color: c.primary)),
                        onTap: () => app.openUrl(service.website!),
                      ),
                    // WhatsApp contact (gap fix — field existed in the
                    // model but was never rendered).
                    if (service.whatsapp != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.chat_outlined,
                            color: c.primary, size: 20),
                        title: Text('whatsapp'.tr,
                            style: AppTextStyles.caption
                                .copyWith(color: c.textTertiary)),
                        subtitle: Text(service.whatsapp!,
                            style: AppTextStyles.phoneNumber
                                .copyWith(color: c.primary)),
                        onTap: () => app.openUrl(
                            'https://wa.me/${service.whatsapp!.replaceAll(RegExp(r'\D'), '')}'),
                      ),
                    // Opening hours by day.
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.space3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel('opening_hours'.tr),
                          if (service.hours.isAlwaysOpen)
                            Text('always_open'.tr,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: c.success))
                          else
                            for (var d = 1; d <= 7; d++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(children: [
                                  SizedBox(
                                      width: 44,
                                      child: Text(_days[d - 1],
                                          style: AppTextStyles.caption
                                              .copyWith(
                                                  color: c.textTertiary))),
                                  Text(
                                    service.hours.byWeekday[d] == null
                                        ? 'closed'.tr
                                        : '${service.hours.byWeekday[d]!.$1} – ${service.hours.byWeekday[d]!.$2}',
                                    style: AppTextStyles.caption.copyWith(
                                        color: service.hours.byWeekday[d] ==
                                                null
                                            ? c.emergency
                                            : c.textPrimary),
                                  ),
                                ]),
                              ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppDimens.space4),

                  // ---- Action buttons: Call / Map / Share ----
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(
                            '${'call'.tr} ${service.primaryPhone.number}'),
                        onPressed: () =>
                            app.callNumber(service.primaryPhone.number),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space2),
                    IconButton.outlined(
                        icon: const Icon(Icons.map_outlined),
                        onPressed: () =>
                            directory.openServiceMap(service)),
                    IconButton.outlined(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => directory.shareService(service)),
                  ]),
                  const SizedBox(height: AppDimens.space3),

                  // ---- Contextual ad strip (one per screen, spec 5.7) ----
                  const AdStrip(),
                  const SizedBox(height: AppDimens.space4),

                  // ---- Reviews section ----
                  SectionLabel('reviews'.tr),
                  if (count > 0) ...[
                    Row(children: [
                      Text(avg.toStringAsFixed(1),
                          style: AppTextStyles.display
                              .copyWith(color: c.textPrimary)),
                      const SizedBox(width: AppDimens.space2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRow(rating: avg, size: 16),
                          Text('$count ${'reviews'.tr}',
                              style: AppTextStyles.caption
                                  .copyWith(color: c.textTertiary)),
                        ],
                      ),
                    ]),
                    const SizedBox(height: AppDimens.space3),
                    // 5★→1★ distribution bars.
                    for (var s = 5; s >= 1; s--)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(children: [
                          SizedBox(
                              width: 22,
                              child: Text('$s★',
                                  style: AppTextStyles.caption
                                      .copyWith(color: c.textTertiary))),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: count == 0
                                    ? 0
                                    : dist[s - 1] / count,
                                minHeight: 6,
                                backgroundColor: c.bgSecondary,
                                color: c.star,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: 26,
                              child: Text(' ${dist[s - 1]}',
                                  style: AppTextStyles.caption
                                      .copyWith(color: c.textTertiary))),
                        ]),
                      ),
                    const SizedBox(height: AppDimens.space3),
                  ],
                  // Write-a-review entry (login-gated in _onWriteReview).
                  // Disabled with a clear label once the user has reviewed.
                  OutlinedButton.icon(
                    icon: Icon(
                        alreadyReviewed
                            ? Icons.check_circle_outline
                            : Icons.edit_outlined,
                        size: 18),
                    label: Text(alreadyReviewed
                        ? 'already_reviewed'.tr
                        : 'write_review'.tr),
                    onPressed:
                        alreadyReviewed ? null : () => _onWriteReview(service),
                  ),
                  const SizedBox(height: AppDimens.space3),
                  // Recent review cards.
                  for (final r in reviews)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppDimens.space2),
                      padding: const EdgeInsets.all(AppDimens.space3),
                      decoration: BoxDecoration(
                        color: c.bgCard,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: c.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            InitialsAvatar(initials: r.initials, size: 30),
                            const SizedBox(width: AppDimens.space2),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(r.displayName,
                                      style: AppTextStyles.bodySm.copyWith(
                                          color: c.textPrimary,
                                          fontWeight: FontWeight.w500)),
                                  Text(r.relativeDate,
                                      style: AppTextStyles.caption
                                          .copyWith(color: c.textTertiary)),
                                ],
                              ),
                            ),
                            StarRow(rating: r.stars.toDouble()),
                          ]),
                          const SizedBox(height: AppDimens.space2),
                          Text(r.text,
                              style: AppTextStyles.body
                                  .copyWith(color: c.textPrimary)),
                          // Experience tag chips.
                          if (r.positiveTags.isNotEmpty ||
                              r.negativeTags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: AppDimens.space2),
                              child: Wrap(
                                spacing: AppDimens.space1,
                                runSpacing: AppDimens.space1,
                                children: [
                                  for (final t in r.positiveTags)
                                    _TagBadge(
                                        text: t.tr,
                                        bg: c.successLight,
                                        fg: c.success),
                                  for (final t in r.negativeTags)
                                    _TagBadge(
                                        text: t.tr,
                                        bg: c.warningLight,
                                        fg: c.warning),
                                ],
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.thumb_up_outlined,
                                  size: 14),
                              label: Text(
                                  '${'helpful'.tr} (${r.helpfulCount})',
                                  style: const TextStyle(fontSize: 12)),
                              onPressed: () => reviewsCtrl.markHelpful(r),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pagination: reveal the next page of reviews.
                  if (moreCount > 0)
                    TextButton(
                      onPressed: reviewsCtrl.loadMoreDetailReviews,
                      child: Text('see_all_reviews'
                          .trParams({'count': '${allReviews.length}'})),
                    ),

                  // ---- Report incorrect info ----
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          directory.reportIncorrectInfo(service),
                      icon: Icon(Icons.flag_outlined,
                          size: 16, color: c.textTertiary),
                      label: Text('report_info'.tr,
                          style: AppTextStyles.caption
                              .copyWith(color: c.textTertiary)),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space6),
                ],
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

/// Small rounded metric chip used in the stats row.
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _MetricChip(
      {required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space2),
        decoration: BoxDecoration(
          color: c.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: AppDimens.space1),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.caption.copyWith(color: c.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card-styled wrapper for the contact table block.
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

/// Tiny tinted badge for review experience tags.
class _TagBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _TagBadge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
        child: Text(text, style: AppTextStyles.label.copyWith(color: fg)),
      );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// CategoryListScreen — services in one category for the active district
/// (spec 4.7). Sort chips (Nearest / Highest rated / Most reviewed / Open
/// now) plus the district chip; empty state offers "Suggest a service".
/// ---------------------------------------------------------------------------
class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final directory = Get.find<DirectoryController>();
    final c = AppColors.of(context);

    return Obx(() {
      final cat = directory.activeCategory.value;
      if (cat == null) return const Scaffold(); // Defensive: no category set
      final meta = categoryMeta(cat);
      final lang = app.language.value;
      final services = directory.categoryServices();

      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Icon(meta.icon, size: 20),
            const SizedBox(width: AppDimens.space2),
            Text(meta.name(lang)),
          ]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: Column(children: [
                const DistrictChip(),
                const SizedBox(height: AppDimens.space3),
                // Sort chips row — selection state lives in the controller.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final (s, label) in const [
                      (ServiceSort.nearest, 'sort_nearest'),
                      (ServiceSort.topRated, 'sort_top_rated'),
                      (ServiceSort.mostReviewed, 'sort_most_reviewed'),
                      (ServiceSort.openNow, 'sort_open_now'),
                    ])
                      Padding(
                        padding:
                            const EdgeInsets.only(right: AppDimens.space2),
                        child: ChoiceChip(
                          label: Text(label.tr),
                          selected: directory.sort.value == s,
                          selectedColor: c.primaryLight,
                          labelStyle: TextStyle(
                              fontSize: 12,
                              color: directory.sort.value == s
                                  ? c.primary
                                  : c.textSecondary),
                          onSelected: (_) => directory.changeSort(s),
                        ),
                      ),
                  ]),
                ),
              ]),
            ),
            // Results list / empty state.
            Expanded(
              child: services.isEmpty
                  ? EmptyState(
                      icon: meta.icon,
                      message: 'no_services'.trParams({
                        'category': meta.name(lang),
                        'district': app.district.value,
                      }),
                      ctaLabel: 'suggest_service'.tr,
                      onCta: directory.suggestService,
                    )
                  // Paginated results: one extra slot renders the
                  // "Load more" button while pages remain.
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space4),
                      itemCount: (services.length >
                                  directory.categoryVisible.value
                              ? directory.categoryVisible.value
                              : services.length) +
                          (services.length > directory.categoryVisible.value
                              ? 1
                              : 0),
                      itemBuilder: (_, i) {
                        if (i >= directory.categoryVisible.value) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.space3),
                            child: OutlinedButton(
                              onPressed: directory.loadMoreCategory,
                              child: Text('load_more'.tr),
                            ),
                          );
                        }
                        return ServiceCard(service: services[i]);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}

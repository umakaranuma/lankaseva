import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/directory_controller.dart';
import '../../controllers/search_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';
import '../widgets/service_card.dart';

/// ---------------------------------------------------------------------------
/// SearchScreen — full-text search tab (spec 4.9). Shows recent searches
/// when empty, grouped results (Services / Categories / Districts) while
/// typing, and a no-results state with fallback CTAs.
/// ---------------------------------------------------------------------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final search = Get.find<ServiceSearchController>();
    final directory = Get.find<DirectoryController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('tab_search'.tr)),
      body: SafeArea(
        child: Column(
          children: [
            // Search input — every keystroke goes to the controller.
            Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: Obx(() => TextField(
                    autofocus: false,
                    controller: TextEditingController.fromValue(
                        TextEditingValue(
                            text: search.query.value,
                            selection: TextSelection.collapsed(
                                offset: search.query.value.length))),
                    decoration: InputDecoration(
                      hintText: 'search_hint'.tr,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: search.query.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => search.onQueryChanged(''))
                          : null,
                    ),
                    onChanged: search.onQueryChanged,
                    onSubmitted: search.rememberSearch,
                  )),
            ),
            Expanded(
              child: Obx(() {
                final lang = app.language.value;
                // ---- Empty query → recent searches ----
                if (search.query.value.trim().isEmpty) {
                  if (search.recentSearches.isEmpty) {
                    return EmptyState(
                        icon: Icons.search, message: 'search_hint'.tr);
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space4),
                    children: [
                      SectionLabel('recent_searches'.tr),
                      for (final term in search.recentSearches)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.history,
                              size: 18, color: c.textTertiary),
                          title: Text(term,
                              style: AppTextStyles.body
                                  .copyWith(color: c.textPrimary)),
                          trailing: IconButton(
                              icon: Icon(Icons.close,
                                  size: 16, color: c.textTertiary),
                              onPressed: () => search.removeRecent(term)),
                          onTap: () => search.onQueryChanged(term),
                        ),
                    ],
                  );
                }
                // ---- No results state ----
                if (search.noResults) {
                  return EmptyState(
                    icon: Icons.search_off,
                    message: 'no_results'
                        .trParams({'query': search.query.value.trim()}),
                    ctaLabel: 'suggest_service'.tr,
                    onCta: directory.suggestService,
                  );
                }
                // ---- Grouped results ----
                return ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space4),
                  children: [
                    if (search.serviceResults.isNotEmpty) ...[
                      SectionLabel('services'.tr),
                      for (final s in search.serviceResults)
                        ServiceCard(service: s),
                    ],
                    if (search.categoryResults.isNotEmpty) ...[
                      SectionLabel('categories'.tr),
                      for (final meta in search.categoryResults)
                        ListTile(
                          leading: Icon(meta.icon, color: meta.color),
                          title: Text(meta.name(lang)),
                          trailing: const Icon(Icons.chevron_right, size: 18),
                          onTap: () {
                            search.rememberSearch(search.query.value);
                            directory.openCategory(meta.id);
                            Get.toNamed(Routes.categoryList);
                          },
                        ),
                    ],
                    if (search.districtResults.isNotEmpty) ...[
                      SectionLabel('districts'.tr),
                      for (final name in search.districtResults)
                        ListTile(
                          leading: Icon(Icons.location_on_outlined,
                              color: c.primary),
                          title: Text(name),
                          onTap: () {
                            search.rememberSearch(name);
                            app.changeDistrict(name);
                            app.changeTab(0); // Jump home with new district
                          },
                        ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

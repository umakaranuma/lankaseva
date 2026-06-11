import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/location_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// ---------------------------------------------------------------------------
/// DistrictScreen — pick one of the 25 districts (spec 4.4). Offers an
/// auto-detect button plus a searchable province-grouped list. On first run
/// confirming completes onboarding; afterwards it simply pops back.
/// ---------------------------------------------------------------------------
class DistrictScreen extends StatefulWidget {
  const DistrictScreen({super.key});

  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  // Local UI filter state only — the chosen district itself lives in
  // AppController (single source of truth).
  String _filter = '';

  /// Districts matching the search field, preserving spec ordering.
  List<District> get _filtered => kDistricts
      .where((d) =>
          d.name.toLowerCase().contains(_filter.toLowerCase()) ||
          d.province.toLowerCase().contains(_filter.toLowerCase()))
      .toList();

  /// Confirms selection: finish onboarding on first run, else pop.
  void _confirm(AppController app) {
    if (app.onboarded.value) {
      Get.back();
    } else {
      app.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('choose_district'.tr)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: Column(
                children: [
                  // GPS auto-detect: LocationController runs the full
                  // permission flow (ask → denied → blocked → settings),
                  // gets a fix and applies the nearest district. The flow
                  // only continues when detection actually succeeded.
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final location = Get.find<LocationController>();
                      return OutlinedButton.icon(
                        icon: location.isLocating.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : const Icon(Icons.my_location, size: 18),
                        label: Text('use_my_location'.tr),
                        onPressed: location.isLocating.value
                            ? null
                            : () async {
                                final ok = await location
                                    .detectAndApplyDistrict();
                                if (ok) _confirm(app);
                              },
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimens.space3),
                  // District search filter.
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'search_districts'.tr,
                      prefixIcon: const Icon(Icons.search, size: 20),
                    ),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ],
              ),
            ),
            // Province-grouped district list.
            Expanded(
              child: Obx(() {
                final selected = app.district.value;
                final items = _filtered;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space4),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final d = items[i];
                    final isSelected = d.name == selected;
                    // Show a province header when it changes.
                    final showHeader =
                        i == 0 || items[i - 1].province != d.province;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: AppDimens.space3,
                                bottom: AppDimens.space1),
                            child: Text(d.province.toUpperCase(),
                                style: AppTextStyles.sectionLabel
                                    .copyWith(color: c.textTertiary)),
                          ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.space3),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusMd)),
                          tileColor: isSelected ? c.primaryLight : null,
                          title: Text(d.name,
                              style: AppTextStyles.heading3.copyWith(
                                  color: isSelected
                                      ? c.primary
                                      : c.textPrimary)),
                          subtitle: Text('${d.province} Province',
                              style: AppTextStyles.caption
                                  .copyWith(color: c.textTertiary)),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: c.primary)
                              : null,
                          onTap: () => app.changeDistrict(d.name),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
            // Confirm.
            Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirm(app),
                  child: Text('confirm'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

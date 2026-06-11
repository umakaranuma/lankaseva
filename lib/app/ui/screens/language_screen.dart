import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';

/// ---------------------------------------------------------------------------
/// LanguageScreen — choose Sinhala / English / Tamil (spec 4.3).
/// Selection switches all strings immediately (live preview). On first run
/// it continues to District Selection; from Settings it just pops back.
/// ---------------------------------------------------------------------------
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  /// Language options: (code, native name, latin name).
  static const _options = [
    ('si', 'සිංහල', 'Sinhala'),
    ('en', 'English', 'English'),
    ('ta', 'தமிழ்', 'Tamil'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final c = AppColors.of(context);
    // From-settings mode pops back instead of continuing the first-run flow.
    final fromSettings = app.onboarded.value;

    return Scaffold(
      appBar: fromSettings ? AppBar(title: Text('language'.tr)) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space4),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimens.space6),
                  Text('choose_language'.tr,
                      style: AppTextStyles.display
                          .copyWith(color: c.textPrimary)),
                  const SizedBox(height: AppDimens.space6),
                  // Three large selectable language cards.
                  for (final (code, native, latin) in _options)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimens.space3),
                      child: _LanguageCard(
                        native: native,
                        latin: latin,
                        selected: app.language.value == code,
                        // Live preview: strings switch instantly (spec 4.3).
                        onTap: () => app.changeLanguage(code),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => fromSettings
                        ? Get.back()
                        : Get.toNamed(Routes.districtSelect),
                    child: Text('continue'.tr),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

/// One selectable language card with the selected-state border + check.
class _LanguageCard extends StatelessWidget {
  final String native;
  final String latin;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageCard({
    required this.native,
    required this.latin,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space4),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: selected ? c.primary : c.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(native,
                      style: AppTextStyles.heading2
                          .copyWith(color: c.textPrimary)),
                  Text(latin,
                      style: AppTextStyles.bodySm
                          .copyWith(color: c.textSecondary)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: c.primary),
          ],
        ),
      ),
    );
  }
}

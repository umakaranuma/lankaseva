import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/report_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// ReportBugScreen — full-page "Report a bug" form opened from Settings →
/// About (spec 4.15). The user picks a category (single choice), describes
/// the problem (10+ chars), and can leave optional contact details. Submit
/// is enabled once category + a meaningful description are present. All
/// state lives in ReportController.
/// ---------------------------------------------------------------------------
class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  /// Icon per bug category for a friendlier, scannable chooser.
  static const _categoryIcons = {
    'bug_crash': Icons.error_outline,
    'bug_display': Icons.broken_image_outlined,
    'bug_slow': Icons.hourglass_empty,
    'bug_feature': Icons.lightbulb_outline,
    'bug_other': Icons.help_outline,
  };

  @override
  void initState() {
    super.initState();
    Get.find<ReportController>().startBugReport();
  }

  /// Submits through the controller and pops with a thank-you toast.
  void _submit(ReportController report) {
    if (report.submitBug()) {
      Get.back();
      AppToast.show('report_sent'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = Get.find<ReportController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('report_bug'.tr)),
      body: SafeArea(
        child: Obx(() => ListView(
              padding: const EdgeInsets.all(AppDimens.space4),
              children: [
                Text('report_bug_intro'.tr,
                    style:
                        AppTextStyles.body.copyWith(color: c.textSecondary)),
                const SizedBox(height: AppDimens.space5),

                // ---- Category (single-choice tappable rows) ----
                SectionLabel('report_bug_type'.tr),
                Container(
                  decoration: BoxDecoration(
                    color: c.bgCard,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: c.borderLight),
                  ),
                  child: Column(children: [
                    for (var i = 0;
                        i < ReportController.bugCategoryKeys.length;
                        i++) ...[
                      _BugTypeRow(
                        icon: _categoryIcons[
                            ReportController.bugCategoryKeys[i]]!,
                        label: ReportController.bugCategoryKeys[i].tr,
                        selected: report.bugCategory.value ==
                            ReportController.bugCategoryKeys[i],
                        onTap: () => report.setBugCategory(
                            ReportController.bugCategoryKeys[i]),
                      ),
                      if (i < ReportController.bugCategoryKeys.length - 1)
                        Divider(height: 1, indent: 52, color: c.borderLight),
                    ],
                  ]),
                ),
                const SizedBox(height: AppDimens.space5),

                // ---- Description ----
                SectionLabel('report_bug_describe'.tr),
                TextField(
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'report_bug_hint'.tr,
                    counterText:
                        '${report.bugDetail.value.length}/500',
                  ),
                  onChanged: report.onBugDetailChanged,
                ),
                const SizedBox(height: AppDimens.space4),

                // ---- Optional contact ----
                SectionLabel('report_contact_optional'.tr),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      InputDecoration(hintText: 'report_contact_hint'.tr),
                  onChanged: report.onBugContactChanged,
                ),
                const SizedBox(height: AppDimens.space5),

                // ---- Submit ----
                ElevatedButton(
                  onPressed:
                      report.canSubmitBug ? () => _submit(report) : null,
                  child: Text('submit_report'.tr),
                ),
                const SizedBox(height: AppDimens.space3),
                Text('report_thanks_note'.tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption
                        .copyWith(color: c.textTertiary)),
              ],
            )),
      ),
    );
  }
}

/// One selectable bug-category row (radio-style with tinted icon chip).
class _BugTypeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BugTypeRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space3, vertical: AppDimens.space3),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (selected ? c.primary : c.textSecondary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm + 2),
            ),
            child: Icon(icon,
                size: 18, color: selected ? c.primary : c.textSecondary),
          ),
          const SizedBox(width: AppDimens.space3),
          Expanded(
            child: Text(label,
                style: AppTextStyles.body.copyWith(color: c.textPrimary)),
          ),
          // Radio indicator.
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 20,
            color: selected ? c.primary : c.textTertiary,
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/report_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/service_model.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// ReportInfoScreen — full-page "Report incorrect info" form opened from a
/// Service Detail page (spec 5.3). The user picks which details are wrong
/// (multi-select chips) and adds an optional note; submit is enabled once
/// at least one issue is flagged. All state lives in ReportController.
/// ---------------------------------------------------------------------------
class ReportInfoScreen extends StatefulWidget {
  const ReportInfoScreen({super.key});

  @override
  State<ReportInfoScreen> createState() => _ReportInfoScreenState();
}

class _ReportInfoScreenState extends State<ReportInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the form for the service passed via route arguments.
    Get.find<ReportController>().startInfoReport(Get.arguments as Service);
  }

  /// Submits through the controller and pops back with a thank-you toast.
  void _submit(ReportController report) {
    if (report.submitInfoReport()) {
      Get.back();
      Get.rawSnackbar(
          message: 'report_sent'.tr, duration: const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final report = Get.find<ReportController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('report_info'.tr)),
      body: SafeArea(
        child: Obx(() {
          final service = report.reportTarget.value;
          if (service == null) return const SizedBox.shrink();
          final meta = categoryMeta(service.category);
          return ListView(
            padding: const EdgeInsets.all(AppDimens.space4),
            children: [
              // ---- Service being reported (read-only header card) ----
              Container(
                padding: const EdgeInsets.all(AppDimens.space3),
                decoration: BoxDecoration(
                  color: c.bgCard,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: c.borderLight),
                ),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle),
                    child: Icon(meta.icon, color: meta.color, size: 20),
                  ),
                  const SizedBox(width: AppDimens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name.of(app.language.value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading3
                                .copyWith(color: c.textPrimary)),
                        Text(service.district,
                            style: AppTextStyles.caption
                                .copyWith(color: c.textTertiary)),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: AppDimens.space5),

              // ---- What's wrong (multi-select chips) ----
              SectionLabel('report_whats_wrong'.tr),
              Wrap(
                spacing: AppDimens.space2,
                runSpacing: AppDimens.space2,
                children: [
                  for (final key in ReportController.infoIssueKeys)
                    FilterChip(
                      label: Text(key.tr, style: const TextStyle(fontSize: 13)),
                      selected: report.infoIssues.contains(key),
                      selectedColor: c.primaryLight,
                      checkmarkColor: c.primary,
                      labelStyle: TextStyle(
                          color: report.infoIssues.contains(key)
                              ? c.primary
                              : c.textSecondary),
                      onSelected: (_) => report.toggleInfoIssue(key),
                    ),
                ],
              ),
              const SizedBox(height: AppDimens.space5),

              // ---- Optional detail ----
              SectionLabel('report_details_optional'.tr),
              TextField(
                maxLines: 4,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'report_info_hint'.tr,
                  counterText: '',
                ),
                onChanged: report.onInfoDetailChanged,
              ),
              const SizedBox(height: AppDimens.space5),

              // ---- Submit ----
              ElevatedButton(
                onPressed:
                    report.canSubmitInfo ? () => _submit(report) : null,
                child: Text('submit_report'.tr),
              ),
              const SizedBox(height: AppDimens.space3),
              Text('report_thanks_note'.tr,
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.caption.copyWith(color: c.textTertiary)),
            ],
          );
        }),
      ),
    );
  }
}

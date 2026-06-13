import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/emergency_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// ---------------------------------------------------------------------------
/// EmergencyScreen — full-screen high-contrast emergency hub (spec 4.6).
/// Intentionally different from the rest of the app: red-tinted background,
/// large numbers, no login, no ads, fully offline (numbers are constants).
/// ---------------------------------------------------------------------------
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  /// Builds the plain-text hotline list for the share button (spec:
  /// "Share this screen" shares as a text list).
  String _shareText() => Get.find<EmergencyController>()
      .hotlines
      .map((e) => '${e.nameKey.tr}: ${e.number}')
      .join('\n');

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.emergencyLight,
      appBar: AppBar(
        backgroundColor: c.emergency,
        title: Text('emergency_contacts'.tr),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space4),
          children: [
            // Header: icon + subtitle.
            Icon(Icons.emergency_outlined, size: 44, color: c.emergency),
            const SizedBox(height: AppDimens.space2),
            Text('emergency_sub'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: c.textSecondary)),
            const SizedBox(height: AppDimens.space4),

            // Full-width high-contrast hotline tiles (from the controller).
            for (final e in Get.find<EmergencyController>().hotlines)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.space2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  // Confirm-then-dial handled centrally in AppController.
                  onTap: () => app.callNumber(e.number),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.space4),
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: Row(children: [
                      Icon(e.icon, color: Colors.white, size: 24),
                      const SizedBox(width: AppDimens.space3),
                      Expanded(
                        child: Text(e.nameKey.tr,
                            style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                      Text(e.number, style: AppTextStyles.emergencyNumber),
                    ]),
                  ),
                ),
              ),

            const SizedBox(height: AppDimens.space3),
            // Share the full list as text (spec behaviour).
            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined, size: 18),
              label: Text('share_screen'.tr),
              onPressed: () => app.shareText(_shareText()),
            ),
          ],
        ),
      ),
    );
  }
}

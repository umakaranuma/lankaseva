import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// ---------------------------------------------------------------------------
/// SplashScreen — brand moment on cold launch (spec 4.1).
/// Shows the wordmark on the primary colour for 1.5 s, then routes to
/// Onboarding (first launch) or the main shell (returning user). The
/// routing decision lives in AppController.startRoute.
/// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1.5 second brand pause, then hand off (spec behaviour).
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.offAllNamed(Get.find<AppController>().startRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Shield logo + trilingual wordmark.
            Icon(Icons.shield_outlined, size: 64, color: c.primaryText),
            const SizedBox(height: 16),
            Text(AppInfo.appName,
                style: AppTextStyles.display.copyWith(color: c.primaryText)),
            Text(AppInfo.appNameLatin,
                style: AppTextStyles.heading3
                    .copyWith(color: c.primaryText.withValues(alpha: 0.85))),
            const SizedBox(height: 12),
            Text('app_tagline'.tr,
                style: AppTextStyles.body
                    .copyWith(color: c.primaryText.withValues(alpha: 0.8))),
            const Spacer(flex: 3),
            Text('v${AppInfo.version}',
                style: AppTextStyles.caption.copyWith(color: AppColors.light.primaryLight)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// AboutScreen — logo, mission, data sources, legal text and contact
/// (spec 4.17). Static content; external links go through AppController.
/// ---------------------------------------------------------------------------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('about'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.space4),
        children: [
          // Logo + version.
          Center(
            child: Column(children: [
              Icon(Icons.shield_outlined, size: 56, color: c.primary),
              const SizedBox(height: AppDimens.space2),
              Text(AppInfo.appName,
                  style: AppTextStyles.heading1.copyWith(color: c.textPrimary)),
              Text('v${AppInfo.version}',
                  style:
                      AppTextStyles.caption.copyWith(color: c.textTertiary)),
            ]),
          ),
          const SizedBox(height: AppDimens.space5),

          // Mission statement (spec 4.17 — one paragraph).
          Text(
            'LankaSeva consolidates every Sri Lankan government service, '
            'emergency hotline and public institution contact into a single '
            'searchable, reviewable, one-tap-callable app — free for all '
            'residents, in Sinhala, English and Tamil, online or offline.',
            style: AppTextStyles.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppDimens.space5),

          // Data sources.
          SectionLabel('Data sources'),
          for (final src in const [
            'Government Information Centre (1919)',
            'Ceylon Electricity Board',
            'National Water Supply & Drainage Board',
            'Ministry of Health hospital directory',
            'Sri Lanka Police station directory',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space1),
              child: Text('• $src',
                  style: AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
            ),
          const SizedBox(height: AppDimens.space5),

          // Legal links.
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined, size: 20),
            title: Text('privacy_policy'.tr),
            onTap: () => app.openUrl('https://lankseva.lk/privacy'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined, size: 20),
            title: Text('terms'.tr),
            onTap: () => app.openUrl('https://lankseva.lk/terms'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline, size: 20),
            title: const Text(AppInfo.contactEmail),
            onTap: () => app.openUrl('mailto:${AppInfo.contactEmail}'),
          ),
          const SizedBox(height: AppDimens.space5),
          Center(
            child: Text('LankaSeva — Built for Sri Lanka. Built by Sri Lanka.',
                style: AppTextStyles.caption.copyWith(color: c.textTertiary)),
          ),
        ],
      ),
    );
  }
}

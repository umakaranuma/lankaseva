import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_pages.dart';

/// ---------------------------------------------------------------------------
/// Shared atom-level UI widgets used across multiple screens. Pure
/// presentation — any behaviour is delegated to controllers via callbacks.
/// ---------------------------------------------------------------------------

/// Uppercase tertiary section label (design rule, spec 2.3).
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space2),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.sectionLabel.copyWith(color: c.textTertiary),
      ),
    );
  }
}

/// Row of star icons rendering a (possibly fractional) rating.
class StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const StarRow({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 0.75;
        final half = !filled && rating >= i + 0.25;
        return Icon(
          filled
              ? Icons.star
              : half
              ? Icons.star_half
              : Icons.star_border,
          size: size,
          color: c.star,
        );
      }),
    );
  }
}

/// Circular avatar showing user initials on a tinted background.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const InitialsAvatar({super.key, required this.initials, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.primaryLight, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: c.primary,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Profile avatar: shows the user's photo when one is set, otherwise the
/// initials circle. Used on the Settings account card.
class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final String initials;
  final double size;
  const UserAvatar({
    super.key,
    required this.imagePath,
    required this.initials,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    // Fall back to initials when no photo (or the file was removed).
    if (path == null || !File(path).existsSync()) {
      return InitialsAvatar(initials: initials, size: size);
    }
    return ClipOval(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// District chip shown on Home / Category List ("Colombo District —
/// Tap to change"), opening the district selector when tapped.
class DistrictChip extends StatelessWidget {
  const DistrictChip({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final c = AppColors.of(context);
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        onTap: () => Get.toNamed(Routes.districtSelect),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space3,
            vertical: AppDimens.space2,
          ),
          decoration: BoxDecoration(
            color: c.bgCard,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: c.borderLight),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: c.primary),
              const SizedBox(width: AppDimens.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${app.district.value} ${'district'.tr}',
                      style: AppTextStyles.heading3.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      'tap_to_change'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contextual ad strip with the mandatory "Ad" label (spec 5.7 — max one
/// per screen, clearly labelled, never on the Emergency screen).
class AdStrip extends StatelessWidget {
  final String headline;
  final String description;
  final IconData icon;
  const AdStrip({
    super.key,
    this.headline = 'Sunpower Solar — Colombo',
    this.description = 'Cut your CEB bill by 80%. Free site visit.',
    this.icon = Icons.campaign_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimens.space2),
      padding: const EdgeInsets.all(AppDimens.space3),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: c.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: c.warning),
          const SizedBox(width: AppDimens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: AppTextStyles.bodySm.copyWith(color: c.textPrimary),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: c.bgSecondary,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Text(
              'ad'.tr,
              style: AppTextStyles.label.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic centred empty-state block with icon, message and optional CTA.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: c.textTertiary),
            const SizedBox(height: AppDimens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: c.textSecondary),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: AppDimens.space4),
              OutlinedButton(onPressed: onCta, child: Text(ctaLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Global floating toast utility matching the application theme.
class AppToast {
  static void show(String message, {bool isError = false}) {
    final context = Get.context;
    if (context == null) return;
    final c = AppColors.of(context);
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: AppTextStyles.body.copyWith(color: c.textPrimary),
      ),
      backgroundColor: c.bgCard,
      icon: Container(
        width: 4,
        height: 20,
        margin: const EdgeInsets.only(left: AppDimens.space2),
        decoration: BoxDecoration(
          color: isError ? c.emergency : c.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      borderColor: isError ? c.emergency : c.primary,
      borderWidth: 1.0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space4,
        vertical: AppDimens.space2,
      ),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppDimens.space4),
      borderRadius: AppDimens.radiusMd,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}

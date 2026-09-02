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

/// Uppercase section label with a short gold accent tick (design rule,
/// spec 2.3 — enriched). Optional [trailing] widget sits at the far end.
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          bottom: AppDimens.space3, top: AppDimens.space1),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            margin: const EdgeInsets.only(right: AppDimens.space2),
            decoration: BoxDecoration(
              color: c.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style:
                  AppTextStyles.sectionLabel.copyWith(color: c.textSecondary),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded-square icon "chip" on a soft tint of [color] — the standard
/// leading glyph for categories, list rows and detail headers.
class IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double radius;

  const IconChip({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.radius = AppDimens.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Lift muted accents so they read on a near-black surface.
    final accent = dark ? Color.lerp(color, Colors.white, 0.45)! : color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: dark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accent.withValues(alpha: dark ? 0.22 : 0.14)),
      ),
      child: Icon(icon, color: accent, size: size * 0.5),
    );
  }
}

/// Soft-filled status pill (e.g. Open / Closed). [color] drives both the
/// tinted background and the label.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const StatusPill({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: icon == null ? 8 : 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: AppTextStyles.label
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.primaryLight, c.secondaryLight],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: c.primary.withValues(alpha: 0.20)),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: c.primary,
          fontWeight: FontWeight.w700,
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
            boxShadow: c.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Icon(Icons.location_on_rounded,
                    size: 18, color: c.primary),
              ),
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
        color: c.secondaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.secondary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          IconChip(icon: icon, color: c.secondaryDark, size: 40),
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
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: c.secondary.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Text(
              'ad'.tr,
              style: AppTextStyles.label.copyWith(color: c.secondaryDark),
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
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: c.primary),
            ),
            const SizedBox(height: AppDimens.space4),
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
      messageText: Row(
        children: [
          Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              color: isError ? c.emergency : c.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: AppDimens.space1),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
      backgroundColor: c.bgCard,
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

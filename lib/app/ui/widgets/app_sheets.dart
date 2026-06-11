import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// ---------------------------------------------------------------------------
/// App-wide bottom-sheet helpers.
///
/// Design rule: LankaSeva never uses popup dialogs — every confirmation
/// and quick action is presented as a bottom sheet (friendlier on mobile,
/// thumb-reachable, consistent with the rest of the UI). All controllers
/// and screens must call [showConfirmSheet] instead of Get.dialog.
/// ---------------------------------------------------------------------------

/// Shows a confirmation bottom sheet and resolves to true when the user
/// taps the confirm action, false otherwise (cancel / swipe-dismiss).
///
/// [destructive] styles the confirm button in the emergency colour for
/// irreversible actions (delete review / account, logout).
Future<bool> showConfirmSheet({
  required String title,
  String? message,
  String? confirmLabel,
  IconData? icon,
  bool destructive = false,
}) async {
  final c = AppColors.of(Get.context!);
  final result = await Get.bottomSheet<bool>(
    SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space5),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle for the sheet affordance.
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimens.space4),
                decoration: BoxDecoration(
                  color: c.borderMedium,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
              ),
            ),
            if (icon != null) ...[
              Icon(icon,
                  size: 36, color: destructive ? c.emergency : c.primary),
              const SizedBox(height: AppDimens.space3),
            ],
            Text(title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(color: c.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: AppDimens.space2),
              Text(message,
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodySm.copyWith(color: c.textSecondary)),
            ],
            const SizedBox(height: AppDimens.space5),
            // Confirm + cancel, stacked full-width for easy thumb reach.
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: c.emergency)
                  : null,
              onPressed: () => Get.back(result: true),
              child: Text(confirmLabel ?? 'yes'.tr),
            ),
            const SizedBox(height: AppDimens.space2),
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr,
                  style: TextStyle(color: c.textSecondary)),
            ),
          ],
        ),
      ),
    ),
  );
  return result == true;
}

/// Shows a bottom sheet with a list of action rows (used for quick menus
/// like change/remove photo). Each action closes the sheet, then runs.
Future<void> showActionsSheet(List<SheetAction> actions) async {
  final c = AppColors.of(Get.context!);
  await Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space3),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXl)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppDimens.space2),
            decoration: BoxDecoration(
              color: c.borderMedium,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
          ),
          for (final action in actions)
            ListTile(
              leading: Icon(action.icon,
                  color: action.destructive ? c.emergency : c.primary),
              title: Text(action.label,
                  style: TextStyle(
                      color: action.destructive
                          ? c.emergency
                          : c.textPrimary)),
              onTap: () {
                Get.back();
                action.onTap();
              },
            ),
        ]),
      ),
    ),
  );
}

/// One row in an actions sheet.
class SheetAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
}

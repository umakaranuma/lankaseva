import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/directory_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notification_model.dart';
import '../../routes/app_pages.dart';
import '../widgets/common_widgets.dart';

/// ---------------------------------------------------------------------------
/// NotificationsScreen — in-app notification centre (spec 5.8). Lists
/// alerts newest first with type icons and unread markers; tapping marks
/// read and deep-links to the related service when one is attached.
/// ---------------------------------------------------------------------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  /// Icon + accent colour for each notification type.
  (IconData, Color) _typeStyle(NotificationType type, AppColors c) =>
      switch (type) {
        NotificationType.emergency => (Icons.warning_amber_outlined, c.emergency),
        NotificationType.serviceUpdate => (Icons.update, c.info),
        NotificationType.reviewReply => (Icons.thumb_up_outlined, c.star),
        NotificationType.newService => (Icons.fiber_new_outlined, c.success),
      };

  /// Tap behaviour: mark read, then open the linked service if any.
  void _onTap(NotificationController ctrl, AppNotification n) {
    ctrl.markRead(n);
    if (n.serviceId != null) {
      final service = Get.find<DirectoryController>().serviceById(n.serviceId!);
      if (service != null) {
        Get.toNamed(Routes.serviceDetail, arguments: service);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr),
        actions: [
          // Mark-all-read shortcut.
          Obx(() => ctrl.unreadCount > 0
              ? TextButton(
                  onPressed: ctrl.markAllRead,
                  child: Text('mark_all_read'.tr,
                      style: const TextStyle(color: Colors.white)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        final items = ctrl.visible;
        if (items.isEmpty) {
          return EmptyState(
              icon: Icons.notifications_none, message: 'no_notifications'.tr);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimens.space4),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final n = items[i];
            final (icon, color) = _typeStyle(n.type, c);
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimens.space2),
              decoration: BoxDecoration(
                // Unread rows get a subtle primary tint to stand out.
                color: n.isRead ? c.bgCard : c.primaryLight,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: c.borderLight),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                onTap: () => _onTap(ctrl, n),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.space3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle),
                        child: Icon(icon, size: 20, color: color),
                      ),
                      const SizedBox(width: AppDimens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title,
                                style: AppTextStyles.heading3.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: n.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(n.body,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: c.textSecondary)),
                            const SizedBox(height: AppDimens.space1),
                            Text(n.relativeDate,
                                style: AppTextStyles.caption
                                    .copyWith(color: c.textTertiary)),
                          ],
                        ),
                      ),
                      // Unread dot indicator.
                      if (!n.isRead)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: c.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

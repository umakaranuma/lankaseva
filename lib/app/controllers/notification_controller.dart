import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/notification_model.dart';
import 'app_controller.dart';

/// ---------------------------------------------------------------------------
/// NotificationController
/// ---------------------------------------------------------------------------
/// In-app notification centre (spec 5.8). Owns:
///   • the notification list (newest first) and reactive unread count —
///     the Home bell badge observes this
///   • read-state persistence across sessions
///   • per-type muting honouring the Settings toggles
///   • tap handling (mark read + optional deep link to a service)
///
/// This build seeds realistic local notifications; a production release
/// would append entries from FCM pushes through the same [add] method.
/// ---------------------------------------------------------------------------
class NotificationController extends GetxController {
  static const _kReadIds = 'notif_read_ids';

  late SharedPreferences _prefs;

  /// All notifications, newest first.
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  /// Unread count for the bell badge (respects per-type mute toggles).
  int get unreadCount =>
      visible.where((n) => !n.isRead).length;

  /// Notifications after applying the Settings mute toggles — a muted
  /// type disappears from the centre entirely (spec: opt-in only).
  List<AppNotification> get visible {
    final prefs = Get.find<AppController>().notifPrefs;
    bool allowed(AppNotification n) => switch (n.type) {
          NotificationType.serviceUpdate => prefs['service_updates'] ?? true,
          NotificationType.emergency => prefs['emergency'] ?? true,
          NotificationType.reviewReply => prefs['replies'] ?? true,
          NotificationType.newService => prefs['service_updates'] ?? true,
        };
    return notifications.where(allowed).toList();
  }

  /// Loads read-state and seeds the demo feed; called from main().
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final readIds = (_prefs.getStringList(_kReadIds) ?? const []).toSet();
    final now = DateTime.now();

    // Seed feed — in production these arrive via push and [add].
    notifications.assignAll([
      AppNotification(
        id: 'n1',
        type: NotificationType.emergency,
        title: 'Weather alert — heavy rain',
        body:
            'The Disaster Management Centre has issued a heavy rainfall warning for your district until tomorrow evening.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.serviceUpdate,
        title: 'CEB hotline updated',
        body:
            'The Ceylon Electricity Board breakdown hotline details were verified and updated.',
        serviceId: 'colombo_ceb',
        createdAt: now.subtract(const Duration(hours: 9)),
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.newService,
        title: 'New service added near you',
        body:
            'A new government service listing was added in your district. Tap to explore.',
        serviceId: 'colombo_secretariat',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.reviewReply,
        title: 'Your review was helpful',
        body: '3 people found your review helpful this week. Thank you!',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

    // Restore read flags.
    for (final n in notifications) {
      n.isRead = readIds.contains(n.id);
    }
    notifications.refresh();
  }

  /// Appends a new notification (entry point for future FCM integration).
  void add(AppNotification notification) {
    notifications.insert(0, notification);
  }

  /// Marks one notification read and persists the flag.
  void markRead(AppNotification n) {
    if (n.isRead) return;
    n.isRead = true;
    notifications.refresh();
    _persistRead();
  }

  /// Marks the whole centre read ("Mark all read" action).
  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    _persistRead();
  }

  /// Saves the set of read ids.
  void _persistRead() {
    _prefs.setStringList(_kReadIds,
        notifications.where((n) => n.isRead).map((n) => n.id).toList());
  }
}

/// Notification categories — mirror the toggle types in Settings
/// (spec 5.8: service updates, emergency alerts, review replies, new
/// services). Each type can be muted independently.
enum NotificationType { serviceUpdate, emergency, reviewReply, newService }

/// ---------------------------------------------------------------------------
/// AppNotification — one entry in the in-app notification centre.
/// ---------------------------------------------------------------------------
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;

  /// Optional deep-link target: a service id to open on tap.
  final String? serviceId;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.serviceId,
    required this.createdAt,
    this.isRead = false,
  });

  /// Relative timestamp label ("2 h ago") for the notification row.
  String get relativeDate {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) return '${diff.inDays} d ago';
    if (diff.inHours >= 1) return '${diff.inHours} h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} min ago';
    return 'Just now';
  }
}

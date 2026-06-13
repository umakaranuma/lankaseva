/// ---------------------------------------------------------------------------
/// Review domain model — mirrors spec section 7 (Review interface).
/// ---------------------------------------------------------------------------
class Review {
  final String id;
  final String serviceId;
  final String userId; // Hashed phone — never displayed
  final String displayName;
  final int stars; // 1–5
  final String text;
  final List<String> positiveTags; // Translation keys, e.g. 'tag_helpful_staff'
  final List<String> negativeTags;
  int helpfulCount;
  final DateTime createdAt;
  DateTime? editedAt;

  Review({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.displayName,
    required this.stars,
    required this.text,
    this.positiveTags = const [],
    this.negativeTags = const [],
    this.helpfulCount = 0,
    required this.createdAt,
    this.editedAt,
  });

  /// Maps the backend's `/api/reviews/` JSON onto the domain model.
  factory Review.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List? ?? const []).cast<Map<String, dynamic>>();
    return Review(
      // All ids are integers on the backend; carry them as strings here.
      id: json['id'].toString(),
      serviceId: json['service'].toString(),
      userId: json['user_id'].toString(),
      displayName: json['display_name'] ?? 'User',
      stars: json['stars'],
      text: json['text'],
      positiveTags: [
        for (final t in tags)
          if (t['is_positive'] == true) t['tag_key'] as String
      ],
      negativeTags: [
        for (final t in tags)
          if (t['is_positive'] != true) t['tag_key'] as String
      ],
      helpfulCount: json['helpful_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at']).toLocal()
          : null,
    );
  }

  /// Initials shown inside the avatar circle (e.g. "Nimal P." → "NP").
  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  /// Relative date label ("3 days ago") for review cards (spec 4.8).
  String get relativeDate {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30} mo ago';
    if (diff.inDays >= 1) return '${diff.inDays} d ago';
    if (diff.inHours >= 1) return '${diff.inHours} h ago';
    return 'Just now';
  }
}

/// ---------------------------------------------------------------------------
/// AppUser domain model — mirrors spec section 7 (User interface).
/// Created after a successful OTP verification; the raw phone number is
/// never stored, only a hash (privacy rule, spec 4.13).
/// ---------------------------------------------------------------------------
class AppUser {
  final String id;
  final String phoneHash;
  String displayName;

  /// Local file path of the user's profile photo (null = initials avatar).
  String? avatarPath;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.phoneHash,
    required this.displayName,
    this.avatarPath,
    required this.createdAt,
  });

  /// Avatar initials derived from the display name.
  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  /// Serialises to a flat map for SharedPreferences persistence.
  Map<String, String> toMap() => {
        'id': id,
        'phoneHash': phoneHash,
        'displayName': displayName,
        'avatarPath': ?avatarPath,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Restores a user from the persisted map; returns null when invalid.
  static AppUser? fromMap(Map<String, String> map) {
    if (map['id'] == null) return null;
    return AppUser(
      id: map['id']!,
      phoneHash: map['phoneHash'] ?? '',
      displayName: map['displayName'] ?? 'User',
      avatarPath: map['avatarPath'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

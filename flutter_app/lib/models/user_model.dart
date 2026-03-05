class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String currency;
  final String? avatarUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.currency = 'TND',
    this.avatarUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'currency': currency,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    fullName: map['fullName'],
    email: map['email'],
    currency: map['currency'] ?? 'TND',
    avatarUrl: map['avatarUrl'],
    createdAt: DateTime.parse(map['createdAt']),
  );

  UserModel copyWith({
    String? fullName,
    String? email,
    String? currency,
    String? avatarUrl,
  }) => UserModel(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    currency: currency ?? this.currency,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt,
  );
}

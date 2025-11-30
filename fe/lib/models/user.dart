enum UserRole { traveller, provider }

class User {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? bio;
  final List<String> interests;
  final String? budgetRange;
  final String? contactPhone;

  User({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.interests = const [],
    this.budgetRange,
    this.contactPhone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'traveller',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      budgetRange: json['budgetRange'],
      contactPhone: json['contactPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'interests': interests,
      'budgetRange': budgetRange,
      'contactPhone': contactPhone,
    };
  }
}

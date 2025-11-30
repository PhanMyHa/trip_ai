class Review {
  final String id;
  final String reviewId;
  final String userId;
  final String serviceId;
  final double rating;
  final String comment;
  final List<String>? photos;
  final bool isVerified;
  final DateTime createdAt;

  // User info (populated)
  final String? userName;
  final String? userAvatar;

  Review({
    required this.id,
    required this.reviewId,
    required this.userId,
    required this.serviceId,
    required this.rating,
    required this.comment,
    this.photos,
    this.isVerified = false,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      reviewId: json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      userName: json['user']?['name'],
      userAvatar: json['user']?['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reviewId': reviewId,
      'userId': userId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

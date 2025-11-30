class Reel {
  final String id;
  final String reelId;
  final String userId;
  final String serviceId;
  final String videoUrl;
  final String caption;
  final List<String> hashtags;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User info (populated)
  final String? userName;
  final String? userAvatar;

  // Service info (populated)
  final String? serviceTitle;
  final String? serviceLocation;

  Reel({
    required this.id,
    required this.reelId,
    required this.userId,
    required this.serviceId,
    required this.videoUrl,
    required this.caption,
    required this.hashtags,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.serviceTitle,
    this.serviceLocation,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['_id'] ?? '',
      reelId: json['reelId'] ?? '',
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      caption: json['caption'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      userName: json['user']?['name'],
      userAvatar: json['user']?['avatarUrl'],
      serviceTitle: json['service']?['title'],
      serviceLocation: json['service']?['location']?['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reelId': reelId,
      'userId': userId,
      'serviceId': serviceId,
      'videoUrl': videoUrl,
      'caption': caption,
      'hashtags': hashtags,
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

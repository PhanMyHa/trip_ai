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

  // lib/models/reel.dart – SỬA NHỎ ĐỂ AN TOÀN 100%
factory Reel.fromJson(Map<String, dynamic> json) {
  final userObj = json['userId'] is Map ? json['userId'] : {};
  final serviceObj = json['serviceId'] is Map ? json['serviceId'] : {};

  return Reel(
    id: json['_id']?.toString() ?? '',
    reelId: json['reelId'] ?? '',
    userId: userObj['_id']?.toString() ?? json['userId']?.toString() ?? '',
    serviceId: serviceObj['_id']?.toString() ?? json['serviceId']?.toString() ?? '',
    videoUrl: json['videoUrl'] ?? '',
    caption: json['caption'] ?? 'Đang khám phá...',
    hashtags: List<String>.from(json['hashtags'] ?? []),
    views: json['views'] ?? 0,
    likes: json['likes'] ?? 0,
    comments: json['comments'] ?? 0,
    shares: json['shares'] ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),

    userName: userObj['name'] ?? 'Người dùng',
    userAvatar: userObj['avatarUrl'],
    serviceTitle: serviceObj['title'],
    serviceLocation: serviceObj['location']?['city'],
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

  Reel copyWith({
    String? id,
    String? reelId,
    String? userId,
    String? serviceId,
    String? videoUrl,
    String? caption,
    List<String>? hashtags,
    int? views,
    int? likes,
    int? comments,
    int? shares,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
    String? serviceTitle,
    String? serviceLocation,
  }) {
    return Reel(
      id: id ?? this.id,
      reelId: reelId ?? this.reelId,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceLocation: serviceLocation ?? this.serviceLocation,
    );
  }
}

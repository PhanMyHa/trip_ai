// lib/screens/app/newsfeed_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:fe/models/reel.dart';
import 'package:fe/screens/traveler/user_profile_screen.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});
  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  List<Reel> _reels = [];
  bool _isLoading = true;
  late PageController _pageController;
  int _currentIndex = 0;

  final Set<String> _viewedReels = {};
  final Set<String> _likedReels = {};

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController?> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoControllers.values.forEach((c) => c.dispose());
    _chewieControllers.values.whereType<ChewieController>().forEach(
      (c) => c.dispose(),
    );
    super.dispose();
  }

  Future<void> _loadReels() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getReels(limit: 30);
      final reels = data.map((e) => Reel.fromJson(e)).toList();

      setState(() {
        _reels = reels;
        _isLoading = false;
      });

      // Khởi tạo 3 video đầu
      for (int i = 0; i < reels.length && i < 3; i++) {
        _initVideo(i);
      }
    } catch (e) {
      print('Load reels error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initVideo(int index) async {
    final url = _reels[index].videoUrl;
    if (url.isEmpty || _videoControllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoControllers[index] = controller;

    try {
      await controller.initialize();
      if (!mounted) return;

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: index == 0,
        looping: true,
        showControls: false,
        allowMuting: true,
        aspectRatio: controller.value.aspectRatio,
      );

      setState(() => _chewieControllers[index] = chewie);
    } catch (e) {
      print("Video init error: $e");
    }
  }

  void _playPause(int index) {
    final ctrl = _chewieControllers[index];
    if (ctrl == null) return;

    setState(() {
      if (ctrl.isPlaying) {
        ctrl.pause();
      } else {
        ctrl.play();
        if (!_viewedReels.contains(_reels[index].id)) {
          _trackView(_reels[index].id);
        }
      }
    });
  }

  Future<void> _trackView(String reelId) async {
    if (_viewedReels.contains(reelId)) return;
    await ApiService.incrementReelView(reelId);
    _viewedReels.add(reelId);
  }

  Future<void> _toggleLike(int index) async {
    final reel = _reels[index];
    final wasLiked = _likedReels.contains(reel.id);
    final success = await ApiService.toggleLikeReel(reel.id);

    if (success && mounted) {
      setState(() {
        if (wasLiked) {
          _likedReels.remove(reel.id);
          _reels[index] = reel.copyWith(likes: reel.likes - 1);
        } else {
          _likedReels.add(reel.id);
          _reels[index] = reel.copyWith(likes: reel.likes + 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_reels.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Chưa có reel nào',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Travel Reels',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReels,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
          // Tạm dừng tất cả video khác
          _chewieControllers.forEach((idx, ctrl) {
            if (idx != i && ctrl != null && ctrl.isPlaying) {
              ctrl.pause();
            }
          });
          // Phát video hiện tại
          _chewieControllers[i]?.play();

          // Preload video kế tiếp
          if (i + 2 < _reels.length && !_videoControllers.containsKey(i + 2)) {
            _initVideo(i + 2);
          }
        },
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final chewie = _chewieControllers[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              // VIDEO CHÍNH
              if (chewie != null &&
                  chewie.videoPlayerController.value.isInitialized)
                GestureDetector(
                  onDoubleTap: () => _toggleLike(index),
                  onTap: () => _playPause(index),
                  child: Chewie(controller: chewie),
                )
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),

              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),

              // Nút tương tác bên phải
              Positioned(
                right: 12,
                bottom: 100,
                child: Column(
                  children: [
                    _actionBtn(
                      icon: _likedReels.contains(reel.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      count: reel.likes,
                      color: _likedReels.contains(reel.id)
                          ? Colors.pinkAccent
                          : Colors.white,
                      onTap: () => _toggleLike(index),
                    ),
                    _actionBtn(icon: Icons.comment, count: reel.comments),
                    _actionBtn(
                      icon: Icons.share,
                      count: reel.shares,
                      onTap: () async {
                        await ApiService.incrementReelShare(reel.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã chia sẻ!')),
                          );
                        }
                      },
                    ),
                    _actionBtn(icon: Icons.remove_red_eye, count: reel.views),
                  ],
                ),
              ),

              // Thông tin người đăng + caption
              // Thông tin người đăng + caption → CÓ THỂ CLICK ĐƯỢC
              Positioned(
                left: 16,
                bottom: 100,
                right: 80,
                child: GestureDetector(
                  onTap: () {
                    print('🔄 Navigating to profile: ${reel.userId}');
                    print('   User name: ${reel.userName}');

                    if (reel.userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không có thông tin người dùng'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(userId: reel.userId),
                      ),
                    ).catchError((e) {
                      print('❌ Navigation error: $e');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: reel.userAvatar != null
                                ? NetworkImage(reel.userAvatar!)
                                : null,
                            child: reel.userAvatar == null
                                ? Text(
                                    reel.userName?[0].toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '@${reel.userName ?? 'user'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reel.caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (reel.hashtags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            reel.hashtags.map((t) => '#$t').join(' '),
                            style: const TextStyle(
                              color: AppColors.secondaryOrange,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      if (reel.serviceTitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.secondaryOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reel.serviceTitle!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ĐÃ SỬA: onTap → onPressed, toFixed → toStringAsFixed
  Widget _actionBtn({
    required IconData icon,
    required int count,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, size: 36, color: color),
            onPressed: onTap, // ĐÃ SỬA: onPressed thay vì onTap
          ),
          Text(
            _formatCount(count),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ĐÃ SỬA: toFixed → toStringAsFixed
  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

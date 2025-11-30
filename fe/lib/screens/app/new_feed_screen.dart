import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


// Mock Video Model
class TravelVideo {
  final String id;
  final String user;
  final String location;
  final String caption;
  final String videoUrl;
  final int likes;
  final int comments;
  final int shares;

  TravelVideo({
    required this.id,
    required this.user,
    required this.location,
    required this.caption,
    required this.videoUrl,
    this.likes = 1200,
    this.comments = 50,
    this.shares = 20,
  });
}

final mockVideos = [
  TravelVideo(
    id: 'V1',
    user: '@dalat_foodie',
    location: 'Đà Lạt',
    caption: 'Top 3 món ăn đường phố phải thử ở Đà Lạt! #dalat #amthuc',
    videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
  ),
  TravelVideo(
    id: 'V2',
    user: '@travel_pro',
    location: 'Phú Quốc',
    caption: 'Bình minh tuyệt đẹp tại Hòn Móng Tay. Cắm trại ngay và luôn!',
    videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
  ),
  TravelVideo(
    id: 'V3',
    user: '@view_hunter',
    location: 'Sapa',
    caption: 'Săn mây mùa đông ở Sapa. Lạnh nhưng đáng giá!',
    videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
  ),
];


class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  // State để mô phỏng video hiện tại
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Travel Reels',
            style: TextStyle(
                color: AppColors.textLight, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: mockVideos.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final video = mockVideos[index];
          return _buildVideoItem(context, video);
        },
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, TravelVideo video) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Video Placeholder
        Image.network(
          'https://placehold.co/600x1000/3C3C3C/FFFFFF?text=Video+Placeholder',
          fit: BoxFit.cover,
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        // UI tương tác (Icon bên phải)
        Positioned(
          right: 15,
          bottom: 100,
          child: Column(
            children: [
              _buildInteractionButton(
                  Icons.favorite, video.likes, Colors.pinkAccent),
              const SizedBox(height: 20),
              _buildInteractionButton(
                  Icons.comment, video.comments, AppColors.textLight),
              const SizedBox(height: 20),
              _buildInteractionButton(
                  Icons.share, video.shares, AppColors.textLight),
              const SizedBox(height: 20),
              _buildInteractionButton(
                  Icons.more_vert, 0, AppColors.textLight, size: 30),
            ],
          ),
        ),

        // Thông tin Video (Bên trái dưới)
        Positioned(
          left: 15,
          bottom: 100,
          right: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.secondaryOrange,
                      child: Icon(Icons.person,
                          size: 18, color: AppColors.textLight)),
                  const SizedBox(width: 8),
                  Text(
                    video.user,
                    style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                video.caption,
                style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.secondaryOrange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    video.location,
                    style: const TextStyle(
                        color: AppColors.secondaryOrange, fontSize: 13),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionButton(
      IconData icon, int count, Color color,
      {double size = 35}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: size),
          onPressed: () {},
        ),
        if (count > 0)
          Text(
            count.toString(),
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
      ],
    );
  }
}
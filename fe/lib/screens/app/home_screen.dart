import 'package:fe/models/data.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:fe/theme/app_theme.dart' ;

class HomeScreen extends StatelessWidget {
  final UserProfile user = mockCurrentUser;
  final List<Place> featuredPlaces = mockPlaces;

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(context),
                  const SizedBox(height: 32),
                  _buildAIRecommendationSection(context),
                  const SizedBox(height: 32),
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),
                  _buildFeaturedPlaces(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- AppBar với chào mừng và Avatar ---
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào mừng trở lại,',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                user.name.split(' ').last,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  // --- Thanh Tìm kiếm ---
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 10),
            Text(
              'Bạn muốn đi đâu hôm nay?',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- Khu vực Gợi ý AI ---
  Widget _buildAIRecommendationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lên lịch cùng AI',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            AIActionButton(
              text: 'Bắt đầu',
              onPressed: () => Navigator.pushNamed(context, '/ai_request'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Để AI lên kế hoạch chuyến đi hoàn hảo theo sở thích của bạn.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        // AI Card
        GradientCard(
          gradientColors: const [AppColors.primaryBlue, AppColors.accentLight],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Travel Planner:',
                style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lên lịch cho chuyến Đà Lạt 3 ngày 2 đêm cùng bạn bè, thích cắm trại và ẩm thực đường phố.',
                style: TextStyle(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/ai_result'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondaryOrange,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Xem lịch trình gần nhất >'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Bộ lọc danh mục ---
  Widget _buildCategoryFilter() {
    final categories = ['Biển', 'Núi', 'Thành phố', 'Nghỉ dưỡng', 'Ẩm thực'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khám phá theo Chủ đề',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = index == 0; // Giả lập chọn Núi
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    // Xử lý lọc
                  },
                  selectedColor: AppColors.secondaryOrange.withOpacity(0.9),
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textLight : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Danh sách địa điểm nổi bật ---
  Widget _buildFeaturedPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Địa điểm nổi bật',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredPlaces.length,
            itemBuilder: (context, index) {
              final place = featuredPlaces[index];
              return _buildPlaceCard(context, place);
            },
          ),
        ),
      ],
    );
  }

  // --- Thẻ Địa điểm ---
  Widget _buildPlaceCard(BuildContext context, Place place) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/place_detail', arguments: place),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  place.coverImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primaryBlue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          place.location,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingDisplay(
                        rating: place.rating, count: place.reviewCount),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
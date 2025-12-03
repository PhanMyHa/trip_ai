import 'package:fe/models/service.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/services/auth_service.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Service> _featuredServices = [];
  bool _isLoading = true;
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = [
    'Tất cả',
    'Hotel',
    'Tour',
    'Restaurant',
    'Flight',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);

    try {
      final services = await ApiService.getServices(
        category: _selectedCategory == 'Tất cả' ? null : _selectedCategory,
        minRating: 4.0, // Chỉ lấy dịch vụ rating >= 4.0
      );

      setState(() {
        _featuredServices = services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading services: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải dữ liệu. Vui lòng thử lại.'),
          ),
        );
      }
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, user),
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
                    _isLoading
                        ? _buildLoadingState()
                        : _featuredServices.isEmpty
                        ? _buildEmptyState()
                        : _buildFeaturedPlaces(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- AppBar với chào mừng và Avatar ---
  Widget _buildSliverAppBar(BuildContext context, user) {
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
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : const NetworkImage(
                      'https://placehold.co/100x100/A0E7E5/3C3C3C?text=User',
                    ),
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
                user?.name.split(' ').last ?? 'Khách',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textDark,
          ),
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
            ),
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
                color: AppColors.textDark,
              ),
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
        GradientCard(
          gradientColors: const [AppColors.primaryBlue, AppColors.accentLight],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🤖 AI sẽ giúp bạn:',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              _buildAIFeature('✅ Lập lịch trình theo sở thích'),
              _buildAIFeature('✅ Gợi ý địa điểm phù hợp ngân sách'),
              _buildAIFeature('✅ Dự báo thời tiết & tips du lịch'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textLight, fontSize: 15),
      ),
    );
  }

  // --- Bộ lọc danh mục ---
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khám phá theo Danh mục',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) _onCategoryChanged(category);
                  },
                  selectedColor: AppColors.secondaryOrange.withOpacity(0.9),
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.textLight
                        : AppColors.textDark,
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

  // --- Loading State ---
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy dịch vụ nào',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc tìm kiếm khác',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // --- Danh sách địa điểm nổi bật ---
  Widget _buildFeaturedPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ nổi bật',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredServices.length,
            itemBuilder: (context, index) {
              final service = _featuredServices[index];
              return _buildServiceCard(context, service);
            },
          ),
        ),
      ],
    );
  }

  // --- Thẻ Dịch vụ ---
  Widget _buildServiceCard(BuildContext context, Service service) {
    return GestureDetector(
      onTap: () {
        // Navigate đến chi tiết service
        Navigator.pushNamed(context, '/place_detail', arguments: service);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  service.images.isNotEmpty
                      ? service.images.first
                      : 'https://via.placeholder.com/400x300.png?text=No+Image',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            service.location.city,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingDisplay(
                      rating: service.rating,
                      count: service.reviewCount,
                    ),
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

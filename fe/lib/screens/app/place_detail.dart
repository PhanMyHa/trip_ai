import 'package:fe/models/service.dart';
import 'package:fe/models/review.dart' as model;
import 'package:fe/screens/app/booking_screen.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Service service;

  const PlaceDetailScreen({super.key, required this.service});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  List<model.Review> _reviews = [];
  bool _isLoadingReviews = true;
  bool _isFavorite = false;
  int _totalReviews = 0;
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReviews();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final result = await ApiService.getServiceReviews(widget.service.id);
      final reviewsList = result['reviews'] as List? ?? [];
      setState(() {
        _reviews = reviewsList
            .map((json) => model.Review.fromJson(json))
            .toList();
        _totalReviews = result['total'] ?? 0;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav = await ApiService.isFavorite(widget.service.id);
      if (mounted) setState(() => _isFavorite = isFav);
    } catch (e) {
      // Không làm gì nếu lỗi
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final success = await ApiService.toggleFavorite(widget.service.id);
      if (success && mounted) {
        setState(() => _isFavorite = !_isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
          ),
        );
      }
    }
  }

  void _showReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewForm(
        serviceId: widget.service.id,
        onReviewSubmitted: () {
          _loadReviews();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailsHeader(),
                    const SizedBox(height: 20),
                    _buildAmenitiesSection(),
                    const SizedBox(height: 20),
                    _buildDescription(),
                    const SizedBox(height: 20),
                    _buildReviewSection(),
                    const SizedBox(height: 100), // Để bottomSheet không che
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBookingBar(),
    );
  }

  // ==================== SLIVER APPBAR VỚI CAROUSEL ====================
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.backgroundLight,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ---- PAGEVIEW (phải nhận gesture nên để dưới cùng) ----
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              itemCount: widget.service.images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.service.images[index],
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),

            // ---- GRADIENT OVERLAY (không bắt gesture) ----
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),

            // ---- INDICATOR (không bắt gesture) ----
            if (widget.service.images.length > 1)
              IgnorePointer(
                child: Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.service.images.asMap().entries.map((e) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == e.key ? 20 : 8,
                        height: 8,
                        // decoration: BoxDecoration(
                        //   color: _currentImageIndex == e.key
                        //       ? const Color.fromARGB(255, 255, 255, 255)
                        //       : const Color.fromARGB(136, 255, 255, 255),
                        //   borderRadius: BorderRadius.circular(4),
                        // ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),

      // ---- BACK BUTTON ----
      leading: Container(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ---- FAVORITE BUTTON ----
      actions: [
        Container(
          margin: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.errorRed : AppColors.textDark,
            ),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.service.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${widget.service.location.city}, ${widget.service.location.province}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RatingDisplay(
              rating: widget.service.rating,
              count: widget.service.reviewCount,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.service.category,
                style: const TextStyle(
                  color: AppColors.secondaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    if (widget.service.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiện ích đi kèm',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.service.amenities.map((a) {
            return Chip(
              label: Text(a, style: const TextStyle(fontSize: 13)),
              backgroundColor: AppColors.accentLight.withOpacity(0.2),
              avatar: const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.primaryBlue,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới thiệu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.service.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.rate_review_rounded, size: 20),
              label: const Text('Viết đánh giá'),
              onPressed: _showReviewDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Chưa có đánh giá nào')),
            ),
          )
        else
          ..._reviews.take(3).map((r) => _buildReviewCard(r)),
        if (_totalReviews > 3)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to full reviews
              },
              child: Text('Xem tất cả ($_totalReviews đánh giá) >'),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(model.Review review) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.userAvatar != null
                      ? NetworkImage(review.userAvatar!)
                      : const NetworkImage(
                          'https://placehold.co/50x50/A0E7E5/3C3C3C?text=U',
                        ),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'Người dùng',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dateFormat.format(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingDisplay(rating: review.rating, count: 0),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment, style: TextStyle(color: Colors.grey.shade800)),
            if (review.photos != null && review.photos!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.photos!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            review.photos![index],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giá từ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Text(
                  '${NumberFormat('#,###', 'vi_VN').format(widget.service.price.toInt())}đ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(
                    service: widget.service,
                    initialTab:
                        widget.service.category.contains('Hotel') ||
                            widget.service.category.contains('Nghỉ dưỡng')
                        ? 'Hotel'
                        : 'Tour',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Đặt ngay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Review Form giữ nguyên như cũ – đã ổn rồi!
class _ReviewForm extends StatefulWidget {
  final String serviceId;
  final VoidCallback onReviewSubmitted;
  const _ReviewForm({required this.serviceId, required this.onReviewSubmitted});
  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final success = await ApiService.createReview(
        serviceId: widget.serviceId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cảm ơn đánh giá của bạn!')),
        );
        widget.onReviewSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi gửi đánh giá')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Viết đánh giá',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.secondaryOrange,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = i + 1.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ trải nghiệm...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.all(16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Gửi đánh giá',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

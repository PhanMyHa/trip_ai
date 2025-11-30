import 'package:fe/models/data.dart';
import 'package:fe/screens/app/booking_screen.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';

// Mock Review Model
class Review {
  final String userName;
  final String avatarUrl;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

final mockReviews = [
  Review(
    userName: 'Minh Hằng',
    avatarUrl: 'https://placehold.co/50x50/F5C9A3/3C3C3C?text=MH',
    rating: 5.0,
    comment: 'Địa điểm tuyệt vời, phòng ốc sạch sẽ và phục vụ chuyên nghiệp. Rất đáng tiền!',
    date: '15/11/2024',
  ),
  Review(
    userName: 'Tuấn Khang',
    avatarUrl: 'https://placehold.co/50x50/A0E7E5/3C3C3C?text=TK',
    rating: 4.5,
    comment: 'Cảnh đẹp nhưng hơi đông người vào cuối tuần. Tổng thể vẫn rất hài lòng.',
    date: '10/11/2024',
  ),
];

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsHeader(),
                _buildDescription(),
                _buildMapSection(),
                _buildReviewSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBookingBar(context),
    );
  }

  // --- Sliver AppBar với Carousel Ảnh ---
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              place.coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textDark),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // --- Phần Header Chi tiết (Tên, Rating, Vị trí) ---
  Widget _buildDetailsHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.name,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    place.location,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  RatingDisplay(rating: place.rating, count: place.reviewCount),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  place.category,
                  style: const TextStyle(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              )
            ],
          ),
          const Divider(height: 30),
        ],
      ),
    );
  }

  // --- Phần Mô tả ---
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giới thiệu',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Text(
            place.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Phần Bản đồ ---
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí trên Bản đồ',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          GradientCard(
            padding: EdgeInsets.zero,
            radius: 20,
            gradientColors: const [Color(0xFF81B622), Color(0xFF96CEB4)], // Màu xanh lá cây cho Map
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage('https://placehold.co/600x200/B2D3C2/3C3C3C?text=Google+Maps+Placeholder'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop)
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.map_rounded, size: 60, color: Colors.white70),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.directions_rounded),
              label: const Text('Chỉ đường'),
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Phần Đánh giá ---
  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá & Bình luận',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          ...mockReviews.map((review) => _buildReviewCard(review)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Xem tất cả đánh giá (120) >'),
            ),
          )
        ],
      ),
    );
  }

  // --- Thẻ Review ---
  Widget _buildReviewCard(Review review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(review.avatarUrl),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                RatingDisplay(rating: review.rating, count: 0),
                const SizedBox(height: 4),
                Text(
                  review.comment,
                  style: TextStyle(color: Colors.grey.shade800),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBookingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Từ chỉ:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              Text(
                '${place.priceFrom.toInt().toString()} VNĐ',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorRed),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // --- CẬP NHẬT CHUYỂN ĐẾN MÀN HÌNH BOOKING MỚI ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(
                    initialTab: place.category == 'Nghỉ dưỡng' ? 'Hotel' : 'Tour',
                    placeName: place.name,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text(
              'Đặt Ngay',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

}
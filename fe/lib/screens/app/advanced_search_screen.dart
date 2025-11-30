import 'package:fe/models/data.dart';
import 'package:fe/screens/app/place_detail.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(100000, 3000000);
  double _rating = 4.0;
  List<String> _selectedTypes = ['Nghỉ dưỡng'];

  final List<String> typeOptions = [
    'Biển',
    'Núi',
    'Thành phố',
    'Nghỉ dưỡng',
    'Khám phá',
    'Ẩm thực'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Kiếm Nâng Cao'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm, khách sạn...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTitle('Loại hình'),
                  _buildTypeFilter(),
                  _buildFilterTitle('Khoảng giá (VNĐ)'),
                  _buildPriceRangeFilter(),
                  _buildFilterTitle('Đánh giá tối thiểu'),
                  _buildRatingFilter(),
                  _buildFilterTitle('Khoảng cách'),
                  _buildDistanceFilter(),
                ],
              ),
            ),
          ),
          _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildFilterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }

  // --- Bộ lọc Loại hình ---
  Widget _buildTypeFilter() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: typeOptions.map((type) {
        final isSelected = _selectedTypes.contains(type);
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTypes.add(type);
              } else {
                _selectedTypes.remove(type);
              }
            });
          },
          selectedColor: AppColors.primaryBlue.withOpacity(0.8),
          checkmarkColor: AppColors.textLight,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.textLight : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }

  // --- Bộ lọc Khoảng giá ---
  Widget _buildPriceRangeFilter() {
    final formatPrice = (double v) =>
        '${(v / 1000).toStringAsFixed(0)}K'; // Hiển thị K cho hàng nghìn

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatPrice(_priceRange.start),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              formatPrice(_priceRange.end),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: 100000,
          max: 10000000,
          divisions: 100,
          activeColor: AppColors.secondaryOrange,
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
      ],
    );
  }

  // --- Bộ lọc Đánh giá ---
  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '${_rating.toStringAsFixed(1)} Sao trở lên',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          ),
        ),
        Slider(
          value: _rating,
          min: 3.0,
          max: 5.0,
          divisions: 4,
          label: _rating.toStringAsFixed(1),
          activeColor: AppColors.primaryBlue,
          inactiveColor: Colors.grey.shade300,
          onChanged: (double value) {
            setState(() {
              _rating = value;
            });
          },
        ),
      ],
    );
  }

  // --- Bộ lọc Khoảng cách ---
  Widget _buildDistanceFilter() {
    return Row(
      children: [
        const Icon(Icons.near_me_rounded, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: 'Dưới 10km',
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              isDense: true,
              border: InputBorder.none,
              filled: false,
            ),
            items: ['Dưới 5km', 'Dưới 10km', 'Dưới 20km', 'Không giới hạn']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              // Xử lý thay đổi khoảng cách
            },
          ),
        ),
      ],
    );
  }

  // --- Phần kết quả tìm kiếm ---
  Widget _buildResultSection() {
    // Giả lập kết quả tìm kiếm dựa trên mock data
    final filteredPlaces = mockPlaces.where((p) => p.rating >= _rating).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tìm thấy ${filteredPlaces.length} kết quả',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Giả lập tìm kiếm và hiển thị kết quả
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Đã tìm kiếm với ${filteredPlaces.length} kết quả.')),
                  );
                },
                icon: const Icon(Icons.send_rounded, color: AppColors.textLight),
                label: const Text('Tìm Kiếm', style: TextStyle(color: AppColors.textLight)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Hiển thị 2 kết quả đầu tiên
          ...filteredPlaces
              .take(2)
              .map((place) => _buildResultCard(context, place))
              .toList(),
        ],
      ),
    );
  }

  // --- Thẻ Kết quả Tìm kiếm ---
  Widget _buildResultCard(BuildContext context, Place place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  place.coverImageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image, size: 30, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RatingDisplay(rating: place.rating, count: place.reviewCount),
                    const SizedBox(height: 4),
                    Text(
                      'Giá: ${place.priceFrom.toInt()} VNĐ',
                      style: const TextStyle(
                          color: AppColors.errorRed, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${place.distanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
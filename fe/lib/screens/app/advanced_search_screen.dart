import 'package:cached_network_image/cached_network_image.dart';
import 'package:fe/models/service.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/screens/app/place_detail.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  List<Service> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // BIẾN QUAN TRỌNG: Ẩn/hiện bộ lọc
  bool _showFilters = true;

  final List<String> typeOptions = [
    'Biển',
    'Núi',
    'Thành phố',
    'Nghỉ dưỡng',
    'Khám phá',
    'Ẩm thực',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _showFilters = false; // ẨN BỘ LỌC KHI TÌM KIẾM
    });

    try {
      String? category;
      if (_selectedTypes.isNotEmpty) {
        if (_selectedTypes.contains('Nghỉ dưỡng')) category = 'Hotel';
        else if (_selectedTypes.contains('Khám phá')) category = 'Tour';
        else if (_selectedTypes.contains('Ẩm thực')) category = 'Restaurant';
      }

      final results = await ApiService.getServices(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        category: category,
        minRating: _rating,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tìm kiếm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Kiếm Nâng Cao'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Tìm khách sạn, tour, nhà hàng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _hasSearched = false;
                            _searchResults.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // NỘI DUNG CHÍNH
          Column(
            children: [
              // BỘ LỌC (chỉ hiện khi chưa tìm hoặc bấm nút filter)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showFilters || !_hasSearched
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilterTitle('Loại hình'),
                              _buildTypeFilter(),
                              _buildFilterTitle('Khoảng giá (VNĐ)'),
                              _buildPriceRangeFilter(),
                              _buildFilterTitle('Đánh giá tối thiểu'),
                              _buildRatingFilter(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // KẾT QUẢ TÌM KIẾM (luôn hiện, chiếm hết phần còn lại)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.03),
                    borderRadius: _showFilters && !_hasSearched
                        ? null
                        : const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Header kết quả
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _hasSearched
                                  ? 'Tìm thấy ${_searchResults.length} kết quả'
                                  : 'Khám phá dịch vụ',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (_hasSearched)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _showFilters = !_showFilters);
                                },
                                icon: Icon(
                                  _showFilters ? Icons.filter_list_off : Icons.tune,
                                  size: 20,
                                ),
                                label: Text(_showFilters ? 'Ẩn bộ lọc' : 'Bộ lọc'),
                              ),
                          ],
                        ),
                      ),

                      // Danh sách kết quả
                      Expanded(
                        child: _isSearching
                            ? const Center(child: CircularProgressIndicator())
                            : _hasSearched && _searchResults.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search_off, size: 80, color: Colors.grey),
                                        SizedBox(height: 16),
                                        Text('Không tìm thấy kết quả', style: TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildResultCard(context, _searchResults[index]),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // NÚT TÌM KIẾM NỔI (khi đang ở chế độ lọc)
          if (!_hasSearched || _showFilters)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _performSearch,
                icon: _isSearching
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.search_rounded),
                label: Text(_isSearching ? 'Đang tìm kiếm...' : 'Tìm kiếm ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Các hàm build giữ nguyên như cũ (chỉ thêm chút style cho đẹp hơn)
  Widget _buildFilterTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      );

  Widget _buildTypeFilter() {
    return Wrap(
      spacing:   8,
      runSpacing: 8,
      children: typeOptions.map((type) {
        final selected = _selectedTypes.contains(type);
        return FilterChip(
          label: Text(type),
          selected: selected,
          onSelected: (v) {
            setState(() {
              v ? _selectedTypes.add(type) : _selectedTypes.remove(type);
            });
          },
          selectedColor: AppColors.primaryBlue,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 100000,
          max: 10000000,
          divisions: 50,
          activeColor: AppColors.secondaryOrange,
          labels: RangeLabels(
            '${(_priceRange.start / 1000).round()}K',
            '${(_priceRange.end / 1000).round()}K',
          ),
          onChanged: (v) => setState(() => _priceRange = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_priceRange.start / 1000).round()}K', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${(_priceRange.end / 1000).round()}K', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Slider(
      value: _rating,
      min: 3.0,
      max: 5.0,
      divisions: 4,
      label: _rating.toStringAsFixed(1),
      activeColor: AppColors.primaryBlue,
      onChanged: (v) => setState(() => _rating = v),
    );
  }

  Widget _buildResultCard(BuildContext context, Service service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(service: service),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: service.images.isNotEmpty ? service.images[0] : '',
                  placeholder: (_, __) => Container(color: Colors.grey[300]),
                  errorWidget: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    RatingDisplay(rating: service.rating, count: service.reviewCount),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat('#,###', 'vi_VN').format(service.price.toInt())}đ',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.errorRed),
                    ),
                    Text(service.location.city, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
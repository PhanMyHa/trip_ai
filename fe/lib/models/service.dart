// lib/models/service.dart
class Service {
  final String id;
  final String serviceId;
  final String providerId;
  final String title;
  final String category;
  final String description;
  final Location location;
  final double price;
  final List<String> images;
  final List<String> amenities;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  Service({
    required this.id,
    required this.serviceId,
    required this.providerId,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.price,
    required this.images,
    required this.amenities,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Xử lý location (hỗ trợ cả kiểu cũ lat/lng + city và kiểu mới location object)
    double lat = 0.0;
    double lng = 0.0;
    String city = "Không rõ";
    String province = "";
    String address = "";

    if (json['location'] != null && json['location'] is Map) {
      final loc = json['location'];
      city = loc['city'] ?? json['city'] ?? city;
      province = loc['province'] ?? province;
      address = loc['address'] ?? json['address'] ?? address;
      lat = (loc['latitude'] ?? loc['lat'] ?? 0).toDouble();
      lng = (loc['longitude'] ?? loc['lng'] ?? 0).toDouble();
    } else {
      // Kiểu cũ: lat, lng, city riêng
      lat = _parseDouble(json['lat'] ?? json['latitude'] ?? 0);
      lng = _parseDouble(json['lng'] ?? json['longitude'] ?? 0);
      city = json['city'] ?? city;
      address = json['address'] ?? json['city'] ?? address;
    }

    // Xử lý images: hỗ trợ cả images[] và galleryUrls (string hoặc array)
    List<String> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      imageList = List<String>.from(json['images']);
    } else if (json['galleryUrls'] != null) {
      if (json['galleryUrls'] is List) {
        imageList = List<String>.from(json['galleryUrls']);
      } else {
        imageList = [json['galleryUrls'] as String];
      }
    }
    if (imageList.isEmpty) {
      imageList = ["https://via.placeholder.com/400x300.png?text=No+Image"];
    }

    // Xử lý amenities: có thể là string phân cách ; hoặc ,
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is List) {
        amenitiesList = List<String>.from(json['amenities']);
      } else if (json['amenities'] is String) {
        amenitiesList = (json['amenities'] as String)
            .split(RegExp(r'[;,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return Service(
      id: json['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      serviceId: json['serviceId']?.toString() ?? 'unknown',
      providerId: json['providerId']?.toString() ?? 'unknown',
      title: json['title'] ?? json['name'] ?? 'Chưa có tiêu đề',
      category: json['category'] ?? 'Tour',
      description: json['description'] ?? '',
      location: Location(
        city: city,
        province: province,
        address: address,
        latitude: lat,
        longitude: lng,
      ),
      price: _parseDouble(json['price'] ?? json['priceFrom'] ?? 0),
      images: imageList,
      amenities: amenitiesList,
      rating: _parseDouble(json['rating'] ?? json['ratingAverage'] ?? 4.5),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  // Helper để parse số an toàn (vì dữ liệu cũ có thể là String)
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }
}

class Location {
  final String city;
  final String province;
  final String address;
  final double latitude;
  final double longitude;

  Location({
    required this.city,
    required this.province,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return '$city, $province';
  }
}
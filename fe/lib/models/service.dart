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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      providerId: json['providerId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceId': serviceId,
      'providerId': providerId,
      'title': title,
      'category': category,
      'description': description,
      'location': location.toJson(),
      'price': price,
      'images': images,
      'amenities': amenities,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'province': province,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Booking {
  final String id;
  final String bookingId;
  final String userId;
  final String serviceId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String paymentStatus; // 'pending', 'paid', 'refunded'
  final String? specialRequests;
  final String? voucherCode;
  final double? discountAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Service details (populated)
  final ServiceDetails? service;

  Booking({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.serviceId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.specialRequests,
    this.voucherCode,
    this.discountAmount,
    required this.createdAt,
    required this.updatedAt,
    this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] is String
          ? json['userId']
          : json['userId']['_id'] ?? '',
      serviceId: json['serviceId'] is String
          ? json['serviceId']
          : json['serviceId']['_id'] ?? '',
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      numberOfGuests: json['numberOfGuests'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      specialRequests: json['specialRequests'],
      voucherCode: json['voucherCode'],
      discountAmount: json['discountAmount']?.toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      service: json['serviceId'] != null && json['serviceId'] is Map
          ? ServiceDetails.fromJson(json['serviceId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'specialRequests': specialRequests,
      'voucherCode': voucherCode,
    };
  }

  int get numberOfDays {
    return checkOutDate.difference(checkInDate).inDays;
  }
}

class ServiceDetails {
  final String id;
  final String title;
  final String category;
  final double price;
  final List<String> images;
  final String locationCity;
  final String locationProvince;

  ServiceDetails({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.images,
    required this.locationCity,
    required this.locationProvince,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      locationCity: json['location']?['city'] ?? '',
      locationProvince: json['location']?['province'] ?? '',
    );
  }
}

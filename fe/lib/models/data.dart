import 'package:flutter/material.dart';
//mongodb+srv://ha:<db_password>@user.pqz8lvz.mongodb.net/?appName=user
// --- ENUM cho Vai trò người dùng ---
enum UserRole {
  traveller,
  provider,
  admin,
}
// -------------------------------------

// --- Data Models ---

// Model người dùng (Traveller/Provider)
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final List<String> interests; // Sở thích (biển, núi, ẩm thực...)
  final String budgetRange; // Ngân sách (Thấp, Trung bình, Cao)
  final UserRole role; // Thêm vai trò

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = 'https://placehold.co/100x100/A0E7E5/3C3C3C?text=User',
    this.bio = 'Yêu thích du lịch khám phá và trải nghiệm ẩm thực địa phương.',
    this.interests = const ['Núi', 'Cắm trại', 'Ẩm thực'],
    this.budgetRange = 'Trung bình',
    this.role = UserRole.traveller, // Giá trị mặc định là Du khách
  });
}

// Model địa điểm du lịch
class Place {
  final String id;
  final String name;
  final String location;
  final String category; // Biển, Núi, Thành phố, Nghỉ dưỡng
  final double rating;
  final int reviewCount;
  final String coverImageUrl;
  final List<String> galleryUrls;
  final double priceFrom; // Giá tham khảo
  final double distanceKm;
  final String description;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 120,
    this.coverImageUrl = 'https://placehold.co/400x300/F5C9A3/3C3C3C?text=Destination+Image',
    this.galleryUrls = const [],
    this.priceFrom = 800000,
    this.distanceKm = 5.2,
    this.description = 'Địa điểm lý tưởng cho chuyến nghỉ dưỡng lãng mạn, không gian yên tĩnh và nhiều hoạt động ngoài trời.',
  });
}

// Model lịch trình AI đề xuất
class AIRecommendation {
  final String queryId;
  final String destination;
  final String travelerProfile;
  final List<DailySchedule> schedule;

  AIRecommendation({
    required this.queryId,
    required this.destination,
    required this.travelerProfile,
    required this.schedule,
  });
}

class DailySchedule {
  final int day;
  final String date;
  final String theme;
  final String weatherForecast;
  final List<Activity> activities;
  final String aiTip;

  DailySchedule({
    required this.day,
    required this.date,
    required this.theme,
    required this.weatherForecast,
    required this.activities,
    required this.aiTip,
  });
}

class Activity {
  final String time;
  final String title;
  final String placeId;
  final String notes;

  Activity({
    required this.time,
    required this.title,
    required this.placeId,
    required this.notes,
  });
}

// Model Voucher/Promotion
class Voucher {
  final String code;
  final String title;
  final String description;
  final double discountValue;
  final String expiryDate;
  final Color color;

  Voucher({
    required this.code,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.expiryDate,
    required this.color,
  });
}

// --- Mock Data ---

final mockCurrentUser = UserProfile(
  id: 'U001',
  name: 'Nguyễn Văn A',
  email: 'vana@example.com',
  interests: ['Núi', 'Cắm trại', 'Chụp ảnh', 'Ẩm thực'],
  budgetRange: 'Trung bình',
  role: UserRole.traveller, // Khởi tạo với vai trò Du khách
);

final mockPlaces = [
  Place(
    id: 'P101',
    name: 'Khách sạn Đồi Thông',
    location: 'Đà Lạt',
    category: 'Nghỉ dưỡng',
    rating: 4.8,
    reviewCount: 350,
    priceFrom: 1800000,
    coverImageUrl: 'https://placehold.co/600x400/81B622/FFFFFF?text=Doi+Thong+Resort',
    galleryUrls: List.generate(3, (index) => 'https://placehold.co/400x300/81B622/FFFFFF?text=Gallery+${index+1}'),
  ),
  Place(
    id: 'P102',
    name: 'Thác Datanla',
    location: 'Đà Lạt',
    category: 'Khám phá',
    rating: 4.5,
    reviewCount: 120,
    priceFrom: 150000,
    coverImageUrl: 'https://placehold.co/600x400/96CEB4/3C3C3C?text=Datanla+Waterfall',
    galleryUrls: List.generate(3, (index) => 'https://placehold.co/400x300/96CEB4/3C3C3C?text=Gallery+${index+1}'),
  ),
  Place(
    id: 'P103',
    name: 'Đà Lạt View (Quán Cà Phê)',
    location: 'Đà Lạt',
    category: 'Giải trí',
    rating: 4.3,
    reviewCount: 200,
    priceFrom: 50000,
    coverImageUrl: 'https://placehold.co/600x400/FFD879/3C3C3C?text=Dalat+View+Cafe',
    galleryUrls: List.generate(3, (index) => 'https://placehold.co/400x300/FFD879/3C3C3C?text=Gallery+${index+1}'),
  ),
  Place(
    id: 'P104',
    name: 'Khách sạn Ngàn Sao',
    location: 'TP.HCM',
    category: 'Thành phố',
    rating: 4.6,
    reviewCount: 50,
    priceFrom: 1200000,
    coverImageUrl: 'https://placehold.co/600x400/FFAAA5/3C3C3C?text=Ngan+Sao+Hotel',
    galleryUrls: List.generate(3, (index) => 'https://placehold.co/400x300/FFAAA5/3C3C3C?text=Gallery+${index+1}'),
  ),
];

final mockVouchers = [
  Voucher(
    code: 'TRAVELAI20',
    title: 'Giảm 20% cho Booking Tour',
    description: 'Áp dụng cho tour du lịch nội địa, đơn hàng tối thiểu 3,000,000 VNĐ.',
    discountValue: 20,
    expiryDate: '31/12/2024',
    color: const Color(0xFFF7B733),
  ),
  Voucher(
    code: 'FLIGHTSAVE500',
    title: 'Giảm 500K Vé Máy Bay',
    description: 'Áp dụng cho chuyến bay khứ hồi quốc tế. Hạn chót sử dụng 30/11/2024.',
    discountValue: 500000,
    expiryDate: '30/11/2024',
    color: const Color(0xFF20A4F3),
  ),
];
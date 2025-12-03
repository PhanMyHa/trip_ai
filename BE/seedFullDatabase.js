// seedFullDatabase.js
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Service = require('./models/Service');
const Review = require('./models/Review');
const Voucher = require('./models/Voucher');
const Booking = require('./models/Booking');
const Itinerary = require('./models/Itinerary');

const seedServices = [ /* giữ nguyên 5 service bạn đã viết */ 
  { serviceId: 'SVC001', title: 'Khách sạn Sunrise Đà Lạt', category: 'Hotel', description: 'Khách sạn sang trọng với view hồ tuyệt đẹp...', location: { city: 'Đà Lạt', province: 'Lâm Đồng', address: '123 Đường Trần Phú', latitude: 11.9404, longitude: 108.4583 }, price: 800000, images: ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800','https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800'], amenities: ['WiFi miễn phí','Bữa sáng','Hồ bơi','Spa','Gym'], rating: 4.7, reviewCount: 156 },
  { serviceId: 'SVC002', title: 'Tour Phú Quốc 3N2Đ', category: 'Tour', description: 'Khám phá thiên đường biển...', location: { city: 'Phú Quốc', province: 'Kiên Giang', address: 'Bãi Trường', latitude: 10.2898, longitude: 103.9840 }, price: 3500000, images: ['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800','https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=800'], amenities: ['Xe đưa đón','Hướng dẫn viên','Bữa ăn'], rating: 4.8, reviewCount: 243 },
  { serviceId: 'SVC003', title: 'Nhà hàng Hải Sản Biển Đông', category: 'Restaurant', description: 'Nhà hàng hải sản tươi sống...', location: { city: 'Nha Trang', province: 'Khánh Hòa', address: '456 Trần Phú', latitude: 12.2388, longitude: 109.1967 }, price: 500000, images: ['https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800','https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800'], amenities: ['View biển','Parking','WiFi'], rating: 4.5, reviewCount: 89 },
  { serviceId: 'SVC004', title: 'Resort 5 Sao Hội An', category: 'Hotel', description: 'Resort cao cấp bên bờ biển...', location: { city: 'Hội An', province: 'Quảng Nam', address: 'Cửa Đại', latitude: 15.8801, longitude: 108.3380 }, price: 2500000, images: ['https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800','https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'], amenities: ['Bể bơi riêng','Spa','Nhà hàng'], rating: 4.9, reviewCount: 312 },
  { serviceId: 'SVC005', title: 'Tour Sapa 4N3Đ', category: 'Tour', description: 'Hành trình khám phá Sapa...', location: { city: 'Sa Pa', province: 'Lào Cai', address: 'Thị trấn Sa Pa', latitude: 22.3364, longitude: 103.8438 }, price: 4200000, images: ['https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800','https://images.unsplash.com/photo-1528127269322-539801943592?w=800'], amenities: ['Khách sạn 3 sao','Xe đưa đón','Vé cáp treo'], rating: 4.6, reviewCount: 178 }
];

async function seedDatabase() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    // 1. XÓA DỮ LIỆU CŨ
    await Promise.all([
      User.deleteMany({}),
      Service.deleteMany({}),
      Review.deleteMany({}),
      Voucher.deleteMany({}),
      Booking.deleteMany({}),
      Itinerary.deleteMany({})
    ]);
    console.log('Cleared old data');

    // 2. TẠO USERS
    const admin = await User.create({
      userId: 'ADMIN001', name: 'Admin TravelAI', email: 'admin@trip.com', password: 'admin123', role: 'admin',
      avatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=FF6B6B&color=fff'
    });

    const provider = await User.create({
      userId: 'PROV001', name: 'Queen Homestay', email: 'queen@provider.com', password: 'provider123', role: 'provider',
      bio: 'Chuỗi homestay view săn mây Đà Lạt', contactPhone: '0909123456',
      avatarUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400'
    });

    const traveller1 = await User.create({
      userId: 'USER001', name: 'Nguyễn Văn A', email: 'user1@trip.com', password: '123456', role: 'traveller',
      interests: ['Biển', 'Ẩm thực'], budgetRange: 'Trung bình',
      avatarUrl: 'https://ui-avatars.com/api/?name=Van+A'
    });

    const traveller2 = await User.create({
      userId: 'USER002', name: 'Trần Thị B', email: 'user2@trip.com', password: '123456', role: 'traveller',
      interests: ['Núi', 'Văn hóa'], budgetRange: 'Cao',
      avatarUrl: 'https://ui-avatars.com/api/?name=Thi+B'
    });

    console.log('Created users (password đều là 123456 hoặc provider123, admin123)');

    // 3. TẠO SERVICES (gắn providerId)
    const servicesWithProvider = seedServices.map(s => ({ ...s, providerId: provider._id }));
    const createdServices = await Service.insertMany(servicesWithProvider);
    console.log(`Inserted ${createdServices.length} services`);

    // 4. TẠO REVIEWS
    const reviews = [
      { userId: traveller1._id, serviceId: createdServices[0]._id, rating: 5, comment: 'Phòng đẹp, view hồ tuyệt vời!', isVerified: true },
      { userId: traveller2._id, serviceId: createdServices[0]._id, rating: 4.5, comment: 'Dịch vụ tốt, nhân viên thân thiện', isVerified: true },
      { userId: traveller1._id, serviceId: createdServices[1]._id, rating: 4.8, comment: 'Tour rất vui, hướng dẫn viên nhiệt tình', isVerified: true },
      { userId: traveller2._id, serviceId: createdServices[2]._id, rating: 4.5, comment: 'Hải sản tươi ngon, view biển đẹp', isVerified: true },
    ];
    const createdReviews = await Review.insertMany(reviews.map((r, i) => ({ ...r, reviewId: `REV00${i+1}` })));
    console.log(`Inserted ${createdReviews.length} reviews`);

    // 5. TẠO VOUCHERS
       // 5. TẠO VOUCHERS (ĐÃ BỔ SUNG description – quan trọng!)
    const vouchers = [
      {
        voucherId: 'VCH001',
        code: 'WELCOME20',
        title: 'Giảm 20% cho lần đặt đầu tiên',
        description: 'Áp dụng cho mọi dịch vụ khi đặt lần đầu tiên. Giảm tối đa 500.000đ.', // THÊM DÒNG NÀY
        discountValue: 20,
        discountType: 'percentage',
        minOrderValue: 1000000,
        maxDiscountAmount: 500000,
        expiryDate: new Date('2026-12-31'),
        isActive: true,
        applicableCategory: 'all',
        usageLimit: 500,
        usedCount: 0
      },
      {
        voucherId: 'VCH002',
        code: 'HOTEL50K',
        title: 'Giảm 50.000đ đặt khách sạn',
        description: 'Giảm ngay 50.000đ khi đặt bất kỳ khách sạn nào từ 800.000đ trở lên.', // THÊM
        discountValue: 50000,
        discountType: 'fixed',
        minOrderValue: 800000,
        expiryDate: new Date('2026-01-31'),
        isActive: true,
        applicableCategory: 'hotel',
        usageLimit: 300,
        usedCount: 0
      },
      {
        voucherId: 'VCH003',
        code: 'SUMMER2025',
        title: 'Hè rực rỡ - Giảm 15%',
        description: 'Ưu đãi mùa hè 2025 - Giảm 15% tối đa 300.000đ cho mọi dịch vụ du lịch.', // THÊM
        discountValue: 15,
        discountType: 'percentage',
        minOrderValue: 1000000,
        maxDiscountAmount: 300000,
        expiryDate: new Date('2025-09-01'),
        isActive: true,
        applicableCategory: 'all',
        usageLimit: 1000,
        usedCount: 0
      },
    ];

    await Voucher.insertMany(vouchers);
    console.log(`Inserted ${vouchers.length} vouchers`);
    // 6. TẠO BOOKINGS
    const bookings = [
      { bookingId: 'BK001', userId: traveller1._id, serviceId: createdServices[0]._id, checkInDate: new Date('2025-12-20'), checkOutDate: new Date('2025-12-23'), numberOfGuests: 2, totalPrice: 2400000, status: 'confirmed', paymentStatus: 'paid' },
      { bookingId: 'BK002', userId: traveller2._id, serviceId: createdServices[1]._id, checkInDate: new Date('2025-01-15'), checkOutDate: new Date('2025-01-18'), numberOfGuests: 4, totalPrice: 14000000, status: 'pending', paymentStatus: 'pending' },
      { bookingId: 'BK003', userId: traveller1._id, serviceId: createdServices[2]._id, checkInDate: new Date('2025-12-25'), checkOutDate: new Date('2025-12-25'), numberOfGuests: 6, totalPrice: 3000000, status: 'confirmed', paymentStatus: 'paid', specialRequests: 'Bàn ngoài trời' },
    ];
    await Booking.insertMany(bookings);
    console.log(`Inserted ${bookings.length} bookings`);

    // 7. TẠO 1 ITINERARY MẪU (AI generated)
    await Itinerary.create({
      itineraryId: 'ITN001',
      userId: traveller1._id,
      destination: 'Đà Lạt',
      travelProfile: { people: 2, budget: 'Trung bình', interests: ['Nhiếp ảnh', 'Ẩm thực'], travelStyle: 'Thư giãn' },
      schedule: [
        {
          day: 1,
          date: '2025-12-20',
          theme: 'Khám phá thành phố sương mù',
          activities: [
            { time: '08:00', title: 'Đón tại sân bay Liên Khương', notes: 'Xe riêng' },
            { time: '10:00', title: 'Nhận phòng Queen Homestay', placeId: createdServices[0]._id.toString() },
            { time: '14:00', title: 'Tham quan Hồ Xuân Hương & Chợ Đà Lạt' }
          ]
        }
      ],
      totalEstimatedCost: 5500000,
      isSaved: true,
      aiGenerated: true
    });
    console.log('Inserted 1 sample itinerary');

    console.log('\nSEED HOÀN TẤT 100%!');
    console.log('Tài khoản test:');
    console.log('• Admin:      admin@trip.com / admin123');
    console.log('• Provider:   queen@provider.com / provider123');
    console.log('• User 1:     user1@trip.com / 123456');
    console.log('• User 2:     user2@trip.com / 123456');

    process.exit(0);
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  }
}

seedDatabase();
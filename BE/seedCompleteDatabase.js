// seedCompleteDatabase.js - FIX LỖI PROVIDERID & CATEGORY ENUM (VIẾT HOA)
require('dotenv').config();
const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
faker.locale = 'vi';

require('./models/User');
require('./models/Service');
const User = mongoose.model('User');
const Service = mongoose.model('Service');

// ====================== 5 SERVICE VIP (GIỮ NGUYÊN + CATEGORY VIẾT HOA) ======================
const VIP_SERVICES = [
  {
    serviceId: 'SVC0001',
    title: 'Khách sạn Sunrise Đà Lạt',
    category: 'Hotel',  // ← VIẾT HOA ĐÚNG ENUM
    description: 'Khách sạn sang trọng với view hồ tuyệt đẹp...',
    location: { city: 'Đà Lạt', province: 'Lâm Đồng', address: '123 Đường Trần Phú', latitude: 11.9404, longitude: 108.4583 },
    price: 800000,
    images: ['https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800','https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800'],
    amenities: ['WiFi miễn phí','Bữa sáng','Hồ bơi','Spa','Gym'],
    rating: 4.7,
    reviewCount: 156,
    isFeatured: true
  },
  {
    serviceId: 'SVC0002',
    title: 'Tour Phú Quốc 3N2Đ',
    category: 'Tour',  // ← VIẾT HOA
    description: 'Khám phá thiên đường biển...',
    location: { city: 'Phú Quốc', province: 'Kiên Giang', address: 'Bãi Trường', latitude: 10.2898, longitude: 103.9840 },
    price: 3500000,
    images: ['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800','https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=800'],
    amenities: ['Xe đưa đón','Hướng dẫn viên','Bữa ăn'],
    rating: 4.8,
    reviewCount: 243,
    isFeatured: true
  },
  {
    serviceId: 'SVC0003',
    title: 'Nhà hàng Hải Sản Biển Đông',
    category: 'Restaurant',  // ← VIẾT HOA
    description: 'Nhà hàng hải sản tươi sống...',
    location: { city: 'Nha Trang', province: 'Khánh Hòa', address: '456 Trần Phú', latitude: 12.2388, longitude: 109.1967 },
    price: 500000,
    images: ['https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800','https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800'],
    amenities: ['View biển','Parking','WiFi'],
    rating: 4.5,
    reviewCount: 89,
    isFeatured: true
  },
  {
    serviceId: 'SVC0004',
    title: 'Resort 5 Sao Hội An',
    category: 'Hotel',  // ← VIẾT HOA
    description: 'Resort cao cấp bên bờ biển...',
    location: { city: 'Hội An', province: 'Quảng Nam', address: 'Cửa Đại', latitude: 15.8801, longitude: 108.3380 },
    price: 2500000,
    images: ['https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800','https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'],
    amenities: ['Bể bơi riêng','Spa','Nhà hàng'],
    rating: 4.9,
    reviewCount: 312,
    isFeatured: true
  },
  {
    serviceId: 'SVC0005',
    title: 'Tour Sapa 4N3Đ',
    category: 'Tour',  // ← VIẾT HOA
    description: 'Hành trình khám phá Sapa...',
    location: { city: 'Sa Pa', province: 'Lào Cai', address: 'Thị trấn Sa Pa', latitude: 22.3364, longitude: 103.8438 },
    price: 4200000,
    images: ['https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800','https://images.unsplash.com/photo-1528127269322-539801943592?w=800'],
    amenities: ['Khách sạn 3 sao','Xe đưa đón','Vé cáp treo'],
    rating: 4.6,
    reviewCount: 178,
    isFeatured: true
  }
];

// KHO ẢNH ĐẸP ĐÚNG CHỦ ĐỀ (mở rộng hơn)
const IMAGE_BANK = {
  Hotel: [
    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
    'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'
  ],
  Tour: [
    'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
    'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=800',
    'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800'
  ],
  Restaurant: [
    'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800'
  ],
  Flight: [
    'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800'
  ]
};

const CITIES = ['Hà Nội', 'TP Hồ Chí Minh', 'Đà Lạt', 'Đà Nẵng', 'Hội An', 'Nha Trang', 'Phú Quốc', 'Vũng Tàu', 'Sapa', 'Huế', 'Hạ Long', 'Cần Thơ', 'Hải Phòng', 'Pleiku', 'Buôn Ma Thuột', 'Quy Nhơn', 'Phan Thiết', 'Côn Đảo', 'Cà Mau'];

async function seedAll() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    // XÓA SẠCH SERVICES CŨ
    await Service.deleteMany({});
    console.log('Đã xóa services cũ');

    // TẠO PROVIDER BẮT BUỘC VÀ KIỂM TRA ID
    let provider = await User.findOne({ role: 'provider' });
    if (!provider) {
      provider = await User.create({
        userId: 'PROV001',
        name: 'Queen Travel Group',
        email: 'provider@trip.com',
        password: 'provider123',  // ← Giả sử schema hash password tự động
        role: 'provider',
        bio: 'Nhà cung cấp dịch vụ du lịch hàng đầu',
        contactPhone: '0909123456'
      });
      console.log('Tạo provider mới thành công. Provider ID:', provider._id.toString());
    } else {
      console.log('Tìm thấy provider cũ. Provider ID:', provider._id.toString());
    }
    if (!provider._id) {
      throw new Error('Không thể tạo provider - kiểm tra schema User!');
    }

    const services = [...VIP_SERVICES.map(s => ({ ...s, providerId: provider._id }))];  // Gán providerId cho VIP

    // SINH 995 SERVICES NỮA VỚI CATEGORY VIẾT HOA
    const CATEGORIES = ['Hotel', 'Tour', 'Restaurant', 'Flight'];  // ← VIẾT HOA ĐÚNG ENUM
    for (let i = 6; i <= 1000; i++) {
      const category = faker.helpers.arrayElement(CATEGORIES);  // ← VIẾT HOA
      const city = faker.helpers.arrayElement(CITIES);

      let title = '';
      switch (category) {
        case 'Hotel':
          title = `${faker.helpers.arrayElement(['Sang Trọng', 'Boutique', 'View Đẹp', 'Hiện Đại'])} ${faker.helpers.arrayElement(['Hotel', 'Resort', 'Homestay', 'Villa'])} ${city}`;
          break;
        case 'Tour':
          title = `Tour ${city} ${faker.number.int({ min: 1, max: 5 })}N${faker.number.int({ min: 1, max: 4 })}Đ - ${faker.commerce.productName()}`;
          break;
        case 'Restaurant':
          title = `Nhà hàng ${faker.company.name()} - ${city}`;
          break;
        case 'Flight':
          const from = faker.helpers.arrayElement(CITIES);
          const to = faker.helpers.arrayElement(CITIES.filter(c => c !== from));
          title = `Vé máy bay ${from} → ${to} - ${faker.helpers.arrayElement(['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'])}`;
          break;
      }

      // Lấy ảnh đúng category (viết hoa key)
      const selectedImages = faker.helpers.arrayElements(IMAGE_BANK[category] || IMAGE_BANK['Hotel'], faker.number.int({ min: 2, max: 3 }));

      services.push({
        serviceId: `SVC${String(i).padStart(4, '0')}`,
        providerId: provider._id,  // ← BẮT BUỘC CÓ ID
        title,
        category,  // ← VIẾT HOA
        description: `Dịch vụ ${category.toLowerCase()} đẳng cấp tại ${city}. ${faker.lorem.sentences(2)}`,
        location: {
          city,
          province: faker.location.state(),
          address: faker.location.streetAddress(),
          latitude: parseFloat(faker.location.latitude({ min: 8.4, max: 23.4, precision: 4 })),
          longitude: parseFloat(faker.location.longitude({ min: 102.1, max: 109.5, precision: 4 })),
        },
        price: faker.number.int({ min: 350000, max: 25000000 }),
        images: selectedImages,
        amenities: faker.helpers.arrayElements(
          category === 'Hotel' ? ['WiFi miễn phí', 'Hồ bơi', 'Spa', 'Gym', 'Nhà hàng', 'Bar', 'Bữa sáng', 'Xe đưa đón sân bay', 'View biển', 'View núi'] :
          category === 'Tour' ? ['Xe đưa đón', 'Hướng dẫn viên', 'Bữa ăn', 'Vé tham quan', 'Bảo hiểm du lịch', 'Nước uống'] :
          category === 'Restaurant' ? ['View biển', 'View thành phố', 'Phòng VIP', 'Nhạc sống', 'Chỗ đậu xe'] :
          ['Hành lý 20kg', 'Bữa ăn trên máy bay', 'Ghế chọn trước', 'WiFi onboard'],
          faker.number.int({ min: 3, max: 8 })
        ),
        rating: faker.number.float({ min: 3.0, max: 5.0, precision: 0.1 }),
        reviewCount: faker.number.int({ min: 0, max: 500 }),
        isAvailable: faker.datatype.boolean({ probability: 0.9 }),
        isActive: true,
        isFeatured: false
      });

      if (i % 100 === 0) console.log(`Đã tạo ${i}/1000 services (ảnh đẹp 100%)`);
    }

    const createdServices = await Service.insertMany(services);
    console.log(`\nHOÀN TẤT! Đã tạo thành công ${createdServices.length} services`);
    console.log('→ Category enum viết hoa đúng: Hotel, Tour, Restaurant, Flight');
    console.log('→ ProviderId gán đúng cho tất cả');
    console.log('→ 5 VIP + 995 faker với ảnh thật đẹp, không lệch chủ đề');

    process.exit(0);
  } catch (err) {
    console.error('Lỗi chi tiết:', err.message);
    if (err.name === 'ValidationError') {
      console.error('Validation errors:', Object.keys(err.errors));
    }
    process.exit(1);
  }
}

seedAll();
require('dotenv').config();
const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
const bcrypt = require('bcryptjs');

faker.locale = 'vi';

require('./models/User');
const User = mongoose.model('User');

const firstNames = [
  'Trần Văn', 'Lê Hoàng', 'Phạm Minh', 'Nguyễn Ngọc', 'Đặng Quang', 'Bùi Anh',
  'Vũ Thành', 'Hoàng Bảo', 'Đỗ Gia', 'Trịnh Quốc', 'Hà Minh', 'Lý Tuấn',
  'Mai Đức', 'Tô Bảo', 'Dương Nhật', 'Từ Minh', 'Khúc Thanh', 'Đinh Công',
  'Chu Văn', 'Nông Ngọc', 'Phan Huy', 'Đoàn Bảo', 'Lương Tuấn', 'Cao Việt',
  'Trương Anh',
  // Nữ
  'Nguyễn Thị', 'Trần Ngọc', 'Lê Thị', 'Phạm Hồng', 'Vũ Mai', 'Hoàng Yến',
  'Đặng Thùy', 'Bùi Lan', 'Hà Thu', 'Lý Diễm', 'Mai Anh', 'Tô Quỳnh',
  'Dương Hương', 'Từ Ngọc', 'Khúc Huyền', 'Đinh Thảo', 'Chu Bảo',
  'Nông Thị', 'Hồ Minh', 'Vương Lan'
];

const lastNames = [
  'An', 'Bình', 'Cường', 'Dũng', 'Dương', 'Giang', 'Hải', 'Hùng', 'Khánh',
  'Linh', 'Minh', 'Nam', 'Ngọc', 'Oanh', 'Phong', 'Quân', 'Sơn', 'Thắng',
  'Tuấn', 'Việt', 'Anh', 'Bảo', 'Châu', 'Duyên', 'Hương', 'Khuê', 'Lan',
  'Mai', 'Ngân', 'Phương', 'Thảo', 'Thúy', 'Thủy', 'Trang', 'Vy', 'Yến',
  'Ánh', 'Hồng', 'Kiều', 'My', 'Nhi'
];

const interestsList = ['Biển', 'Núi', 'Ẩm thực', 'Văn hóa', 'Chụp ảnh', 'Nghỉ dưỡng', 'Mạo hiểm', 'Cắm trại', 'Thành phố', 'Lịch sử'];
const budgetList = ['Thấp', 'Trung bình', 'Cao'];

async function seedFresh100Users() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    // 1. Xóa tất cả user cũ
    const del = await User.deleteMany({});
    console.log(`Đã xóa ${del.deletedCount} user cũ`);

    const usersToCreate = [];

    const hashedPassword = await bcrypt.hash('123456', 10);

    // 2. 100 traveller
    for (let i = 1; i <= 100; i++) {
      const first = faker.helpers.arrayElement(firstNames);
      const last = faker.helpers.arrayElement(lastNames);

      const fullName =
        first.includes('Thị') || Math.random() > 0.5
          ? `${first} ${last}`
          : `${first.replace(/Văn|Hoàng|Minh/g, 'Thị')} ${last}`;

      const interests = faker.helpers.arrayElements(
        interestsList,
        faker.number.int({ min: 2, max: 5 })
      );

      usersToCreate.push({
        userId: `USER${String(i).padStart(3, '0')}`,
        name: fullName.trim(),
        email: `user${i}@trip.com`,
        password: hashedPassword,
        role: 'traveller',
        interests,
        budgetRange: faker.helpers.arrayElement(budgetList),
        avatarUrl: `https://ui-avatars.com/api/?name=${encodeURIComponent(
          fullName
        )}&background=random&color=fff&bold=true&size=256&rounded=true`,
        isActive: true,
        createdAt: faker.date.between({ from: '2025-01-01', to: new Date() })
      });
    }

    // 3. Thêm 2 provider
    const providers = [
      {
        userId: 'PROV001',
        name: 'Công ty du lịch Đại Dương',
        email: 'provider1@trip.com',
        password: hashedPassword,
        role: 'provider',
        interests: [],
        budgetRange: 'Cao',
        avatarUrl: `https://ui-avatars.com/api/?name=Dai+Duong&background=random&color=fff&size=256&rounded=true`,
        isActive: true
      },
      {
        userId: 'PROV002',
        name: 'Travel Service Việt Nam',
        email: 'provider2@trip.com',
        password: hashedPassword,
        role: 'provider',
        interests: [],
        budgetRange: 'Trung bình',
        avatarUrl: `https://ui-avatars.com/api/?name=Travel+VN&background=random&color=fff&size=256&rounded=true`,
        isActive: true
      }
    ];

    usersToCreate.push(...providers);

    // Insert tất cả
    await User.insertMany(usersToCreate);

    console.log('\nHOÀN TẤT SEED USER');
    console.log('→ 100 traveller');
    console.log('→ 2 provider (PROV001, PROV002)');
    console.log('→ Password chung (hashed): 123456');

    console.log('\nVí dụ login:');
    console.log('   user1@trip.com / 123456');
    console.log('   provider1@trip.com / 123456');

    process.exit(0);
  } catch (err) {
    console.error('Lỗi:', err.message);
    process.exit(1);
  }
}

seedFresh100Users();

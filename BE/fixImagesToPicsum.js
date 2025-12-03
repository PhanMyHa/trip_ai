// fixImagesToPicsum.js
require('dotenv').config();
const mongoose = require('mongoose');
require('./models/Service');

async function fix() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('Connected');

  const services = await mongoose.model('Service').find({});

  for (let i = 0; i < services.length; i++) {
    const svc = services[i];
    const id = svc.serviceId || i;

    await mongoose.model('Service').updateOne(
      { _id: svc._id },
      {
        $set: {
          images: [
            `https://picsum.photos/seed/svc${id}/800/600`,
            `https://picsum.photos/seed/svc${id}a/800/600`,
            `https://picsum.photos/seed/svc${id}b/800/600`,
            `https://picsum.photos/seed/svc${id}c/800/600`
          ]
        }
      }
    );

    if (i % 200 === 0) console.log(`Đã fix ${i + 1}/${services.length}`);
  }

  console.log('HOÀN TẤT! Tất cả ảnh đã chuyển sang Picsum – giờ hiện đẹp 100% trên mobile!');
  process.exit();
}

fix();
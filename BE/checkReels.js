require('dotenv').config();
const mongoose = require('mongoose');
const Reel = require('./models/Reel');

mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB Connected');
    
    const count = await Reel.countDocuments();
    console.log(`📊 Total reels in database: ${count}`);
    
    const reels = await Reel.find().limit(3);
    console.log('\n📄 Sample reels:');
    reels.forEach((reel, i) => {
      console.log(`${i + 1}. ID: ${reel._id}`);
      console.log(`   ReelId: ${reel.reelId}`);
      console.log(`   Caption: ${reel.caption.substring(0, 50)}...`);
      console.log(`   VideoUrl: ${reel.videoUrl.substring(0, 60)}...`);
      console.log(`   Stats: ${reel.views} views, ${reel.likes} likes`);
      console.log('');
    });
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });

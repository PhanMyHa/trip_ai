require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');

mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ Connected to MongoDB');
    
    const users = await User.find().limit(3);
    console.log(`\n📊 Found ${users.length} users:\n`);
    
    users.forEach((user, i) => {
      console.log(`${i + 1}. ID: ${user._id}`);
      console.log(`   Name: ${user.name}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Role: ${user.role}`);
      console.log('');
    });
    
    if (users.length > 0) {
      console.log(`\n🔗 Test URL: http://localhost:5000/api/users/${users[0]._id}`);
    }
    
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });

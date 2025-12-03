const axios = require('axios');

async function testAI() {
  try {
    console.log('🔐 Logging in...');
    const loginRes = await axios.post('http://localhost:5000/api/auth/login', {
      email: 'user1@trip.com',
      password: '123456'
    });
    
    const token = loginRes.data.token;
    console.log('✅ Login successful\n');

    console.log('🤖 Calling AI API...');
    const aiRes = await axios.post(
      'http://localhost:5000/api/ai/recommend-itinerary',
      {
        destination: 'Đà Nẵng',
        startDate: '2025-12-10',
        endDate: '2025-12-13',
        travelers: 2,
        budget: 'Trung bình',
        interests: ['beach', 'food']
      },
      {
        headers: { Authorization: `Bearer ${token}` }
      }
    );

    console.log('\n✅ SUCCESS!');
    console.log('Days:', aiRes.data.data.days);
    console.log('Total Cost:', aiRes.data.data.totalEstimatedCost);
    console.log('Schedule days:', aiRes.data.data.dailySchedule.length);
    
  } catch (error) {
    console.error('\n❌ ERROR:', error.response?.data || error.message);
  }
}

testAI();

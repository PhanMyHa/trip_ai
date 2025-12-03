const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

// Test data
const testUser = {
  email: 'user1@trip.com',
  password: '123456'
};

const testItineraryRequest = {
  destination: 'Đà Nẵng',
  startDate: '2024-06-01',
  endDate: '2024-06-03',
  travelers: 2,
  budget: 'Trung bình',
  interests: ['beach', 'food', 'relaxation']
};

async function testAI() {
  try {
    console.log('🔐 Step 1: Login...');
    const loginRes = await axios.post(`${BASE_URL}/auth/login`, testUser);
    const token = loginRes.data.token;
    console.log('✅ Login successful');

    console.log('\n🤖 Step 2: Get Model Info...');
    const modelInfoRes = await axios.get(`${BASE_URL}/ai/model-info`);
    console.log('Model Info:', JSON.stringify(modelInfoRes.data, null, 2));

    console.log('\n🎯 Step 3: Generate AI Itinerary...');
    const itineraryRes = await axios.post(
      `${BASE_URL}/ai/recommend-itinerary`,
      testItineraryRequest,
      {
        headers: { Authorization: `Bearer ${token}` }
      }
    );

    console.log('\n📋 AI Generated Itinerary:');
    console.log('Destination:', itineraryRes.data.data.destination);
    console.log('Days:', itineraryRes.data.data.days);
    console.log('Total Cost:', itineraryRes.data.data.totalEstimatedCost.toLocaleString(), 'VND');
    
    console.log('\nDaily Schedule:');
    itineraryRes.data.data.dailySchedule.forEach((day, index) => {
      console.log(`\n  Day ${day.day}: ${day.theme}`);
      console.log(`  💡 ${day.ai_tip}`);
      day.activities.forEach(activity => {
        console.log(`    ${activity.time} - ${activity.title} (${activity.price.toLocaleString()} VND)`);
      });
    });

    console.log('\n✅ All tests passed!');
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testAI();

const http = require('http');

// Test 1: Get user by ID (should work without auth)
const testUserId = '692e981da83bbc5e472133ef'; // Real user ID from database

console.log('🧪 Testing User Routes...\n');

// Test getUserById
console.log('1️⃣ Testing GET /api/users/:id (public)');
const options1 = {
  hostname: 'localhost',
  port: 5000,
  path: `/api/users/${testUserId}`,
  method: 'GET',
  headers: { 'Content-Type': 'application/json' }
};

const req1 = http.request(options1, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log(`   Status: ${res.statusCode}`);
    if (res.statusCode === 200) {
      const json = JSON.parse(data);
      console.log('   ✅ Success');
      console.log(`   User: ${json.name || json.data?.name || 'N/A'}`);
    } else {
      console.log(`   ❌ Failed: ${data.substring(0, 100)}`);
    }
    console.log('');
    testProfileRoute();
  });
});

req1.on('error', e => console.error('❌ Request error:', e.message));
req1.end();

// Test getUserProfile (needs auth)
function testProfileRoute() {
  console.log('2️⃣ Testing GET /api/users/profile (protected)');
  const options2 = {
    hostname: 'localhost',
    port: 5000,
    path: '/api/users/profile',
    method: 'GET',
    headers: { 'Content-Type': 'application/json' }
  };

  const req2 = http.request(options2, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      console.log(`   Status: ${res.statusCode}`);
      if (res.statusCode === 401) {
        console.log('   ✅ Correctly requires authentication');
      } else if (res.statusCode === 200) {
        console.log('   ⚠️ Should require auth but returned 200');
      } else {
        console.log(`   Response: ${data.substring(0, 100)}`);
      }
      process.exit(0);
    });
  });

  req2.on('error', e => console.error('❌ Request error:', e.message));
  req2.end();
}

const http = require('http');

const userId = '692e981da83bbc5e472133ef';
const url = `http://localhost:5000/api/users/${userId}`;

console.log(`Testing: ${url}\n`);

http.get(url, (res) => {
  let data = '';
  
  res.on('data', chunk => data += chunk);
  
  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Headers:', JSON.stringify(res.headers, null, 2));
    console.log('\nBody:', data);
    
    if (res.statusCode === 200) {
      try {
        const json = JSON.parse(data);
        console.log('\n✅ Success!');
        console.log('User:', json.name);
      } catch (e) {
        console.log('\n❌ Failed to parse JSON');
      }
    }
  });
}).on('error', (e) => {
  console.error('❌ Error:', e.message);
});

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// IN RA ĐỂ KIỂM TRA
console.log('MONGO_URI:', process.env.MONGO_URI); // ← Phải hiện link MongoDB, nếu là undefined là sai .env
console.log('JWT_SECRET:', process.env.JWT_SECRET ? 'Đã có' : 'Không có');

if (!process.env.MONGO_URI) {
  console.error('LỖI: Thiếu MONGO_URI trong file .env');
  process.exit(1);
}

const app = express();

// Kết nối MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB Connected Successfully'))
.catch(err => {
  console.error('MongoDB Connection Error:', err.message);
  process.exit(1);
});

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/authRoutes'));

app.get('/', (req, res) => {
  res.send('Travel AI Backend đang chạy...');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server đang chạy tại http://192.168.1.19:${PORT}`);
});
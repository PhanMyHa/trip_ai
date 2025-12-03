const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
  serviceId: {
    type: String,
    unique: true,
    required: true
  },
  providerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: ['Hotel', 'Tour', 'Restaurant', 'Flight'],
    required: true
  },
  description: {
    type: String,
    required: true
  },
  location: {
    city: {
      type: String,
      required: true
    },
    province: String,
    address: String,
    latitude: Number,
    longitude: Number
  },
  price: {
    type: Number,
    required: true
  },
  images: [{
    type: String
  }],
  amenities: [{
    type: String
  }],
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  reviewCount: {
    type: Number,
    default: 0
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Index cho search
serviceSchema.index({ title: 'text', description: 'text' });
serviceSchema.index({ category: 1, rating: -1 });
serviceSchema.index({ 'location.city': 1 });

module.exports = mongoose.model('Service', serviceSchema);

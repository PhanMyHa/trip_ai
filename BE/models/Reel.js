const mongoose = require('mongoose');

const reelSchema = new mongoose.Schema({
  reelId: {
    type: String,
    unique: true,
    required: true
  },
  userId: {
    type: String,
    ref: 'User',
    required: true
  },
  videoUrl: {
    type: String,
    required: true
  },
  thumbnailUrl: String,
  caption: String,
  location: String,
  likes: [{
    userId: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  comments: [{
    userId: String,
    text: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  views: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Reel', reelSchema);
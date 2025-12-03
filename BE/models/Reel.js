const mongoose = require('mongoose');

const reelSchema = new mongoose.Schema({
  reelId: {
    type: String,
    required: true,
    unique: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  serviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    required: true
  },
  videoUrl: {
    type: String,
    required: true
  },
  caption: {
    type: String,
    required: true
  },
  hashtags: [{
    type: String
  }],
  views: {
    type: Number,
    default: 0
  },
  likes: {
    type: Number,
    default: 0
  },
  comments: {
    type: Number,
    default: 0
  },
  shares: {
    type: Number,
    default: 0
  },
  likedBy: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }]
}, {
  timestamps: true
});

// Index for better query performance
reelSchema.index({ userId: 1, createdAt: -1 });
reelSchema.index({ serviceId: 1 });
reelSchema.index({ hashtags: 1 });

module.exports = mongoose.model('Reel', reelSchema);

const mongoose = require('mongoose');

const itinerarySchema = new mongoose.Schema({
  itineraryId: {
    type: String,
    unique: true,
    required: true
  },
  userId: {
    type: String,
    ref: 'User',
    required: true
  },
  destination: {
    type: String,
    required: true
  },
  travelProfile: {
    people: Number,
    budget: String,
    interests: [String]
  },
  schedule: [{
    day: Number,
    title: String,
    activities: [String]
  }],
  isSaved: {
    type: Boolean,
    default: false
  },
  aiGenerated: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Itinerary', itinerarySchema);
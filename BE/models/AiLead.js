const mongoose = require('mongoose');

const aiLeadSchema = new mongoose.Schema({
  leadId: {
    type: String,
    unique: true,
    required: true
  },
  userId: {
    type: String,
    ref: 'User',
    required: true
  },
  providerId: {
    type: String,
    ref: 'User',
    required: true
  },
  matchScore: {
    type: Number,
    required: true,
    min: 0,
    max: 100
  },
  userProfile: {
    interests: [String],
    budgetRange: String,
    preferredDestinations: [String]
  },
  providerServices: [String],
  status: {
    type: String,
    enum: ['new', 'contacted', 'converted', 'ignored'],
    default: 'new'
  },
  aiRecommendation: String
}, {
  timestamps: true
});

module.exports = mongoose.model('AiLead', aiLeadSchema);
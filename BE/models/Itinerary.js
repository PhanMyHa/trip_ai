const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema({
  time: String,
  title: String,
  placeId: String,
  notes: String,
  estimatedDuration: Number,
  estimatedCost: Number
}, { _id: false });

const dailyScheduleSchema = new mongoose.Schema({
  day: Number,
  date: String,
  theme: String,
  weatherForecast: String,
  aiTip: String,
  activities: [activitySchema]
}, { _id: false });

const travelProfileSchema = new mongoose.Schema({
  people: Number,
  budget: String,
  interests: [String],
  travelStyle: String
}, { _id: false });

const itinerarySchema = new mongoose.Schema({
  itineraryId: {
    type: String,
    unique: true,
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  destination: {
    type: String,
    required: true
  },
  travelProfile: travelProfileSchema,
  schedule: [dailyScheduleSchema],
  isSaved: {
    type: Boolean,
    default: false
  },
  aiGenerated: {
    type: Boolean,
    default: true
  },
  queryId: String,
  totalEstimatedCost: Number,
  status: {
    type: String,
    enum: ['draft', 'planned', 'active', 'completed', 'cancelled'],
    default: 'draft'
  }
}, {
  timestamps: true
});

itinerarySchema.index({ userId: 1, createdAt: -1 });
itinerarySchema.index({ destination: 1 });

module.exports = mongoose.model('Itinerary', itinerarySchema);

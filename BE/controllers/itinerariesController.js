// const Itinerary = require('../models/Itinerary');
// const User = require('../models/User');
// const Service = require('../models/Service');

// // @desc    Generate AI Itinerary
// // @route   POST /api/itineraries/generate
// // @access  Private
// const generateItinerary = async (req, res) => {
//   try {
//     const { destination, travelProfile, days } = req.body;
//     const userId = req.user.userId;

//     // Simple AI logic - find services matching user profile
//     const user = await User.findOne({ userId });
//     const userInterests = user.interests || [];
    
//     // Find relevant services
//     const services = await Service.find({
//       'location.city': new RegExp(destination, 'i'),
//       isActive: true
//     }).limit(10);

//     // Generate schedule based on interests
//     const schedule = [];
//     for (let day = 1; day <= (days || 2); day++) {
//       const dayActivities = [];
      
//       if (userInterests.includes('beach')) {
//         dayActivities.push('Tắm biển', 'Thể thao nước');
//       }
//       if (userInterests.includes('food')) {
//         dayActivities.push('Thưởng thức ẩm thực địa phương');
//       }
//       if (userInterests.includes('culture')) {
//         dayActivities.push('Tham quan di tích lịch sử');
//       }
      
//       // Add some default activities
//       if (dayActivities.length === 0) {
//         dayActivities.push('Khám phá thành phố', 'Mua sắm');
//       }

//       schedule.push({
//         day,
//         title: `Ngày ${day} - ${destination}`,
//         activities: dayActivities
//       });
//     }

//     // Create itinerary
//     const itineraryId = 'i' + Date.now().toString().slice(-6);
//     const itinerary = await Itinerary.create({
//       itineraryId,
//       userId,
//       destination,
//       travelProfile,
//       schedule,
//       aiGenerated: true,
//       isSaved: true
//     });

//     res.status(201).json(itinerary);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get user itineraries
// // @route   GET /api/itineraries
// // @access  Private
// const getItineraries = async (req, res) => {
//   try {
//     const itineraries = await Itinerary.find({ 
//       userId: req.user.userId 
//     }).sort({ createdAt: -1 });

//     res.json(itineraries);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   generateItinerary,
//   getItineraries
// };
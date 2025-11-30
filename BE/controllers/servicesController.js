// const Service = require('../models/Service');
// const Review = require('../models/Review');

// // @desc    Get all services
// // @route   GET /api/services
// // @access  Public
// const getServices = async (req, res) => {
//   try {
//     const { category, city, minPrice, maxPrice, page = 1, limit = 10 } = req.query;
    
//     let filter = { isActive: true };
    
//     if (category) filter.category = category;
//     if (city) filter['location.city'] = new RegExp(city, 'i');
//     if (minPrice || maxPrice) {
//       filter.price = {};
//       if (minPrice) filter.price.$gte = parseFloat(minPrice);
//       if (maxPrice) filter.price.$lte = parseFloat(maxPrice);
//     }

//     const services = await Service.find(filter)
//       .populate('providerId', 'name avatarUrl')
//       .limit(limit * 1)
//       .skip((page - 1) * limit)
//       .sort({ createdAt: -1 });

//     const total = await Service.countDocuments(filter);

//     res.json({
//       services,
//       totalPages: Math.ceil(total / limit),
//       currentPage: page,
//       total
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get service by ID
// // @route   GET /api/services/:id
// // @access  Public
// const getServiceById = async (req, res) => {
//   try {
//     const service = await Service.findOne({ 
//       serviceId: req.params.id 
//     }).populate('providerId', 'name avatarUrl contactPhone');

//     if (!service) {
//       return res.status(404).json({ message: 'Service not found' });
//     }

//     // Get reviews for this service
//     const reviews = await Review.find({ serviceId: req.params.id })
//       .populate('userId', 'name avatarUrl')
//       .sort({ createdAt: -1 });

//     res.json({
//       ...service.toObject(),
//       reviews
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Create new service (Provider only)
// // @route   POST /api/services
// // @access  Private
// const createService = async (req, res) => {
//   try {
//     const serviceId = 's' + Date.now().toString().slice(-6);
    
//     const service = await Service.create({
//       ...req.body,
//       serviceId,
//       providerId: req.user.userId
//     });

//     res.status(201).json(service);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   getServices,
//   getServiceById,
//   createService
// };
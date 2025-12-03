const Service = require('../models/Service');
const Review = require('../models/Review');

// @desc    Get all services with filters
// @route   GET /api/services
// @access  Public
exports.getServices = async (req, res) => {
  try {
    const { category, minPrice, maxPrice, minRating, city, search } = req.query;
    
    let filter = { isActive: true, isAvailable: true };
    
    if (category && category !== 'Tất cả') {
      filter.category = category;
    }
    
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }
    
    if (minRating) {
      filter.rating = { $gte: Number(minRating) };
    }
    
    if (city) {
      filter['location.city'] = new RegExp(city, 'i');
    }
    
    if (search) {
      filter.$text = { $search: search };
    }
    
    const services = await Service.find(filter)
      .populate('providerId', 'name contactPhone')
      .sort({ rating: -1, createdAt: -1 })
      .limit(50);
    
    res.json(services);
  } catch (error) {
    console.error('Error in getServices:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get service by ID
// @route   GET /api/services/:id
// @access  Public
exports.getServiceById = async (req, res) => {
  try {
    // Try to find by serviceId first, if it fails try by MongoDB _id
    let service = await Service.findOne({ serviceId: req.params.id })
      .populate('providerId', 'name contactPhone email avatarUrl');
    
    // If not found by serviceId and the id looks like a MongoDB ObjectId, try that
    if (!service && req.params.id.match(/^[0-9a-fA-F]{24}$/)) {
      service = await Service.findById(req.params.id)
        .populate('providerId', 'name contactPhone email avatarUrl');
    }
    
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    res.json(service);
  } catch (error) {
    console.error('Error in getServiceById:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get reviews for a service
// @route   GET /api/services/:id/reviews
// @access  Public
exports.getServiceReviews = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    
    const reviews = await Review.find({ 
      serviceId: req.params.id 
    })
      .populate('userId', 'name avatarUrl')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const count = await Review.countDocuments({ serviceId: req.params.id });
    
    res.json({
      reviews,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count
    });
  } catch (error) {
    console.error('Error in getServiceReviews:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a review
// @route   POST /api/services/:id/reviews
// @access  Private
exports.createReview = async (req, res) => {
  try {
    const { rating, comment, photos } = req.body;
    
    // Check if service exists
    const service = await Service.findById(req.params.id);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    // Check if user already reviewed
    const existingReview = await Review.findOne({
      userId: req.user.id,
      serviceId: req.params.id
    });
    
    if (existingReview) {
      return res.status(400).json({ message: 'You already reviewed this service' });
    }
    
    // Create review
    const review = await Review.create({
      reviewId: `REV${Date.now()}`,
      userId: req.user.id,
      serviceId: req.params.id,
      rating,
      comment,
      photos: photos || []
    });
    
    // Update service rating
    const reviews = await Review.find({ serviceId: req.params.id });
    const avgRating = reviews.reduce((acc, item) => item.rating + acc, 0) / reviews.length;
    
    service.rating = avgRating;
    service.reviewCount = reviews.length;
    await service.save();
    
    // Populate user info
    const populatedReview = await Review.findById(review._id)
      .populate('userId', 'name avatarUrl');
    
    res.status(201).json(populatedReview);
  } catch (error) {
    console.error('Error in createReview:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Toggle favorite service
// @route   POST /api/services/:id/favorite
// @access  Private
exports.toggleFavorite = async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    if (!user.favorites) {
      user.favorites = [];
    }
    
    const index = user.favorites.indexOf(req.params.id);
    
    if (index > -1) {
      user.favorites.splice(index, 1);
      await user.save();
      res.json({ message: 'Removed from favorites', isFavorite: false });
    } else {
      user.favorites.push(req.params.id);
      await user.save();
      res.json({ message: 'Added to favorites', isFavorite: true });
    }
  } catch (error) {
    console.error('Error in toggleFavorite:', error);
    res.status(500).json({ message: error.message });
  }
};
// const Review = require('../models/Review');
// const Service = require('../models/Service');
// const Booking = require('../models/Booking');

// // @desc    Get all reviews
// // @route   GET /api/reviews
// // @access  Public
// const getReviews = async (req, res) => {
//   try {
//     const { serviceId, page = 1, limit = 10 } = req.query;
    
//     let filter = {};
//     if (serviceId) filter.serviceId = serviceId;

//     const reviews = await Review.find(filter)
//       .populate('userId', 'name avatarUrl')
//       .populate('serviceId', 'title')
//       .limit(limit * 1)
//       .skip((page - 1) * limit)
//       .sort({ createdAt: -1 });

//     const total = await Review.countDocuments(filter);

//     res.json({
//       reviews,
//       totalPages: Math.ceil(total / limit),
//       currentPage: page,
//       total
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get review by ID
// // @route   GET /api/reviews/:id
// // @access  Public
// const getReviewById = async (req, res) => {
//   try {
//     const review = await Review.findOne({ reviewId: req.params.id })
//       .populate('userId', 'name avatarUrl')
//       .populate('serviceId', 'title');

//     if (!review) {
//       return res.status(404).json({ message: 'Review not found' });
//     }

//     res.json(review);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Create new review
// // @route   POST /api/reviews
// // @access  Private
// const createReview = async (req, res) => {
//   try {
//     const { serviceId, rating, comment } = req.body;
//     const userId = req.user.userId;

//     // Check if user has booked this service
//     const booking = await Booking.findOne({
//       userId,
//       serviceId,
//       status: 'completed'
//     });

//     if (!booking) {
//       return res.status(400).json({ message: 'You can only review services you have booked and completed' });
//     }

//     // Check if user already reviewed this service
//     const existingReview = await Review.findOne({ userId, serviceId });
//     if (existingReview) {
//       return res.status(400).json({ message: 'You have already reviewed this service' });
//     }

//     const reviewId = 'r' + Date.now().toString().slice(-6);
    
//     const review = await Review.create({
//       reviewId,
//       userId,
//       serviceId,
//       rating,
//       comment
//     });

//     await review.populate([
//       { path: 'userId', select: 'name avatarUrl' },
//       { path: 'serviceId', select: 'title' }
//     ]);

//     res.status(201).json(review);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Update review
// // @route   PUT /api/reviews/:id
// // @access  Private
// const updateReview = async (req, res) => {
//   try {
//     const review = await Review.findOne({ reviewId: req.params.id });
    
//     if (!review) {
//       return res.status(404).json({ message: 'Review not found' });
//     }

//     // Only review author can update
//     if (review.userId.toString() !== req.user.userId) {
//       return res.status(403).json({ message: 'Not authorized to update this review' });
//     }

//     const { rating, comment } = req.body;
//     review.rating = rating || review.rating;
//     review.comment = comment || review.comment;
    
//     await review.save();
//     res.json(review);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Delete review
// // @route   DELETE /api/reviews/:id
// // @access  Private
// const deleteReview = async (req, res) => {
//   try {
//     const review = await Review.findOne({ reviewId: req.params.id });
    
//     if (!review) {
//       return res.status(404).json({ message: 'Review not found' });
//     }

//     // Only review author or admin can delete
//     if (review.userId.toString() !== req.user.userId && req.user.role !== 'admin') {
//       return res.status(403).json({ message: 'Not authorized to delete this review' });
//     }

//     await Review.deleteOne({ reviewId: req.params.id });
//     res.json({ message: 'Review deleted successfully' });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   getReviews,
//   getReviewById,
//   createReview,
//   updateReview,
//   deleteReview
// };
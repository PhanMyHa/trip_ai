// const express = require('express');
// const {
//   getReviews,
//   getReviewById,
//   createReview,
//   updateReview,
//   deleteReview
// } = require('../controllers/reviewsController');
// const { protect } = require('../middleware/auth');

// const router = express.Router();

// // Public routes
// router.get('/', getReviews);
// router.get('/:id', getReviewById);

// // Protected routes
// router.post('/', protect, createReview);
// router.put('/:id', protect, updateReview);
// router.delete('/:id', protect, deleteReview);

// module.exports = router;
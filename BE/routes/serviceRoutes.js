const express = require('express');
const serviceController = require('../controllers/serviceController');
const auth = require('../middleware/auth');

const router = express.Router();

// Public routes - specific routes MUST come before :id routes
router.get('/', serviceController.getServices);
router.get('/:id', serviceController.getServiceById);
router.get('/:id/reviews', serviceController.getServiceReviews);

// Protected routes
router.post('/:id/reviews', auth, serviceController.createReview);
router.post('/:id/favorite', auth, serviceController.toggleFavorite);

module.exports = router;
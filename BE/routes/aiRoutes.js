const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const auth = require('../middleware/auth');

// Generate AI itinerary (protected route)
router.post('/recommend-itinerary', auth, aiController.generateItinerary);

// Get model info (public)
router.get('/model-info', aiController.getModelInfo);

module.exports = router;

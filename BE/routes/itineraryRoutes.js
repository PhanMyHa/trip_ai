const express = require('express');
const router = express.Router();
const itineraryController = require('../controllers/itineraryController');
const auth = require('../middleware/auth');

// All routes require authentication
router.use(auth);

router.get('/', itineraryController.getUserItineraries);
router.get('/:id', itineraryController.getItineraryById);
router.post('/', itineraryController.createItinerary);
router.put('/:id', itineraryController.updateItinerary);
router.post('/:id/save', itineraryController.toggleSaveItinerary);
router.delete('/:id', itineraryController.deleteItinerary);

module.exports = router;

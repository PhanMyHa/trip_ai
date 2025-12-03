const express = require('express');
const router = express.Router();
const reelController = require('../controllers/reelController');
const protect = require('../middleware/auth');

// Public routes (specific routes first, then generic :id routes)
router.get('/', reelController.getReels);
router.get('/service/:serviceId', reelController.getReelsByService);
router.get('/user/:userId', reelController.getReelsByUser);
router.get('/:id', reelController.getReelById);

// Protected routes
router.post('/', protect, reelController.createReel);
router.post('/:id/like', protect, reelController.toggleLikeReel);
router.post('/:id/view', reelController.incrementView);
router.post('/:id/share', reelController.incrementShare);
router.delete('/:id', protect, reelController.deleteReel);

module.exports = router;

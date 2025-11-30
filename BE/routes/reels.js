// const express = require('express');
// const {
//   getReels,
//   getReelById,
//   createReel,
//   updateReel,
//   deleteReel
// } = require('../controllers/reelsController');
// const { protect, authorize } = require('../middleware/auth');

// const router = express.Router();

// // Public routes
// router.get('/', getReels);
// router.get('/:id', getReelById);

// // Protected routes (Provider and Admin only)
// router.post('/', protect, authorize('provider', 'admin'), createReel);
// router.put('/:id', protect, authorize('provider', 'admin'), updateReel);
// router.delete('/:id', protect, authorize('provider', 'admin'), deleteReel);

// module.exports = router;
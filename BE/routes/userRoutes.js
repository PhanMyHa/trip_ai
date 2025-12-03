const express = require('express');
const {
  getUserProfile,
  updateUserProfile,
  getUserBookings,
  getUserFavorites,
  changePassword,
  getUserById
} = require('../controllers/userController');
const auth = require('../middleware/auth');

const router = express.Router();

// Protected routes - specific paths must come BEFORE generic :id pattern
router.get('/profile', auth, getUserProfile);
router.put('/profile', auth, updateUserProfile);
router.get('/bookings', auth, getUserBookings);
router.get('/favorites', auth, getUserFavorites);
router.put('/password', auth, changePassword);

// Public route - generic :id pattern must be LAST
router.get('/:id', getUserById);

module.exports = router;

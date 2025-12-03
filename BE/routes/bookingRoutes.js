const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const auth = require('../middleware/auth');

// Tất cả routes yêu cầu authentication
router.use(auth);

// User booking routes
router.post('/', bookingController.createBooking);
router.get('/', bookingController.getUserBookings);
router.get('/stats', bookingController.getBookingStats);
router.get('/:id', bookingController.getBookingById);
router.put('/:id/status', bookingController.updateBookingStatus);
router.post('/:id/cancel', bookingController.cancelBooking);
router.post('/:id/confirm-payment', bookingController.confirmPayment);

module.exports = router;

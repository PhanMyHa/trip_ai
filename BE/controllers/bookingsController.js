// const Booking = require('../models/Booking');
// const Service = require('../models/Service');
// const User = require('../models/User');

// // @desc    Create new booking
// // @route   POST /api/bookings
// // @access  Private
// const createBooking = async (req, res) => {
//   try {
//     const { serviceId, startDate, endDate, guests, specialRequests } = req.body;
//     const userId = req.user.userId;

//     // Verify service exists
//     const service = await Service.findOne({ serviceId });
//     if (!service) {
//       return res.status(404).json({ message: 'Service not found' });
//     }

//     const bookingId = 'b' + Date.now().toString().slice(-6);
    
//     const booking = await Booking.create({
//       bookingId,
//       userId,
//       serviceId,
//       providerId: service.providerId,
//       startDate,
//       endDate,
//       guests,
//       specialRequests,
//       totalPrice: service.price * guests,
//       status: 'pending'
//     });

//     await booking.populate([
//       { path: 'userId', select: 'name email phone' },
//       { path: 'serviceId', select: 'title price location' }
//     ]);

//     res.status(201).json(booking);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get user bookings
// // @route   GET /api/bookings
// // @access  Private
// const getBookings = async (req, res) => {
//   try {
//     const bookings = await Booking.find({ userId: req.user.userId })
//       .populate('serviceId', 'title price location images')
//       .populate('providerId', 'name contactPhone')
//       .sort({ createdAt: -1 });

//     res.json(bookings);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Update booking status
// // @route   PUT /api/bookings/:id/status
// // @access  Private
// const updateBookingStatus = async (req, res) => {
//   try {
//     const { status } = req.body;
//     const bookingId = req.params.id;

//     const booking = await Booking.findOne({ bookingId });
//     if (!booking) {
//       return res.status(404).json({ message: 'Booking not found' });
//     }

//     // Only provider or admin can update status
//     if (req.user.role !== 'admin' && booking.providerId !== req.user.userId) {
//       return res.status(403).json({ message: 'Not authorized to update this booking' });
//     }

//     booking.status = status;
//     await booking.save();

//     res.json(booking);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   createBooking,
//   getBookings,
//   updateBookingStatus
// };
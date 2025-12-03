const Booking = require('../models/Booking');
const Service = require('../models/Service');
const errorHandler = require('../utils/errorHandler');
const successResponse = require('../utils/response');

// Tạo booking mới
exports.createBooking = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      serviceId,
      checkInDate,
      checkOutDate,
      numberOfGuests,
      specialRequests,
      voucherCode
    } = req.body;

    // Kiểm tra service tồn tại
    const service = await Service.findById(serviceId);
    if (!service) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy dịch vụ'
      });
    }

    if (!service.isAvailable) {
      return res.status(400).json({
        success: false,
        message: 'Dịch vụ hiện không khả dụng'
      });
    }

    // Tính số ngày
    const checkIn = new Date(checkInDate);
    const checkOut = new Date(checkOutDate);
    const days = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));

    // Tính tổng giá
    let totalPrice = service.price * days * numberOfGuests;

    // Áp dụng voucher nếu có
    if (voucherCode) {
      const Voucher = require('../models/Voucher');
      const voucher = await Voucher.findOne({ 
        code: voucherCode.toUpperCase(),
        isActive: true,
        expiryDate: { $gt: new Date() }
      });

      if (voucher && voucher.isValid()) {
        const discount = voucher.calculateDiscount(totalPrice);
        totalPrice -= discount;
      }
    }

    // Tạo booking
    const booking = await Booking.create({
      bookingId: `BK${Date.now()}`,
      userId,
      serviceId,
      checkInDate,
      checkOutDate,
      numberOfGuests,
      totalPrice,
      specialRequests,
      status: 'pending',
      paymentStatus: 'pending'
    });

    // Populate thông tin service
    await booking.populate('serviceId', 'title category location price images');

    res.status(201).json(successResponse('Tạo booking thành công', booking));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Lấy danh sách booking của user
exports.getUserBookings = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    const filter = { userId };
    if (status) filter.status = status;

    const bookings = await Booking.find(filter)
      .populate('serviceId', 'title category location price images')
      .sort({ createdAt: -1 });

    res.json(successResponse('Lấy danh sách booking thành công', bookings));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Lấy chi tiết booking
exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await Booking.findOne({ 
      _id: id, 
      userId 
    }).populate('serviceId', 'title category description location price images amenities');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy booking'
      });
    }

    res.json(successResponse('Lấy chi tiết booking thành công', booking));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Cập nhật trạng thái booking
exports.updateBookingStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, paymentStatus } = req.body;
    const userId = req.user.id;

    const booking = await Booking.findOne({ _id: id, userId });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy booking'
      });
    }

    if (status) booking.status = status;
    if (paymentStatus) booking.paymentStatus = paymentStatus;

    await booking.save();

    res.json(successResponse('Cập nhật trạng thái thành công', booking));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Hủy booking
exports.cancelBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await Booking.findOne({ _id: id, userId });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy booking'
      });
    }

    if (booking.status === 'completed' || booking.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Không thể hủy booking này'
      });
    }

    booking.status = 'cancelled';
    await booking.save();

    res.json(successResponse('Hủy booking thành công', booking));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Xác nhận thanh toán
exports.confirmPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await Booking.findOne({ _id: id, userId });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy booking'
      });
    }

    booking.paymentStatus = 'paid';
    booking.status = 'confirmed';
    await booking.save();

    res.json(successResponse('Xác nhận thanh toán thành công', booking));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Lấy thống kê booking (cho provider)
exports.getBookingStats = async (req, res) => {
  try {
    const userId = req.user.id;

    // Lấy danh sách service của provider
    const services = await Service.find({ providerId: userId });
    const serviceIds = services.map(s => s._id);

    // Thống kê
    const totalBookings = await Booking.countDocuments({ 
      serviceId: { $in: serviceIds } 
    });

    const confirmedBookings = await Booking.countDocuments({ 
      serviceId: { $in: serviceIds },
      status: 'confirmed'
    });

    const revenue = await Booking.aggregate([
      { 
        $match: { 
          serviceId: { $in: serviceIds },
          paymentStatus: 'paid'
        }
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$totalPrice' }
        }
      }
    ]);

    const stats = {
      totalBookings,
      confirmedBookings,
      totalRevenue: revenue.length > 0 ? revenue[0].total : 0
    };

    res.json(successResponse('Lấy thống kê thành công', stats));
  } catch (error) {
    errorHandler(res, error);
  }
};

const Voucher = require('../models/Voucher');
const errorHandler = require('../utils/errorHandler');
const successResponse = require('../utils/response');

// Lấy danh sách voucher khả dụng
exports.getVouchers = async (req, res) => {
  try {
    const { category, isActive = true } = req.query;
    
    const filter = {
      isActive,
      expiryDate: { $gt: new Date() }
    };

    if (category && category !== 'all') {
      filter.$or = [
        { applicableCategory: category },
        { applicableCategory: 'all' }
      ];
    }

    const vouchers = await Voucher.find(filter)
      .select('-__v')
      .sort({ createdAt: -1 });

    const validVouchers = vouchers.filter(v => v.isValid());

    res.json(successResponse('Lấy danh sách voucher thành công', validVouchers));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Lấy chi tiết voucher theo code
exports.getVoucherByCode = async (req, res) => {
  try {
    const { code } = req.params;
    
    const voucher = await Voucher.findOne({ 
      code: code.toUpperCase(),
      isActive: true,
      expiryDate: { $gt: new Date() }
    });

    if (!voucher) {
      return res.status(404).json({
        success: false,
        message: 'Voucher không tồn tại hoặc đã hết hạn'
      });
    }

    if (!voucher.isValid()) {
      return res.status(400).json({
        success: false,
        message: 'Voucher đã hết lượt sử dụng'
      });
    }

    res.json(successResponse('Voucher hợp lệ', voucher));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Áp dụng voucher
exports.applyVoucher = async (req, res) => {
  try {
    const { code, orderValue, category } = req.body;

    if (!code || !orderValue) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu thông tin code hoặc orderValue'
      });
    }

    const voucher = await Voucher.findOne({ 
      code: code.toUpperCase(),
      isActive: true,
      expiryDate: { $gt: new Date() }
    });

    if (!voucher || !voucher.isValid()) {
      return res.status(400).json({
        success: false,
        message: 'Mã voucher không hợp lệ'
      });
    }

    if (category && voucher.applicableCategory !== 'all' && 
        voucher.applicableCategory !== category.toLowerCase()) {
      return res.status(400).json({
        success: false,
        message: `Voucher chỉ áp dụng cho ${voucher.applicableCategory}`
      });
    }

    if (orderValue < voucher.minOrderValue) {
      return res.status(400).json({
        success: false,
        message: `Đơn hàng tối thiểu ${voucher.minOrderValue.toLocaleString('vi-VN')} VNĐ`
      });
    }

    const discount = voucher.calculateDiscount(orderValue);

    res.json(successResponse('Áp dụng voucher thành công', {
      voucher: {
        code: voucher.code,
        title: voucher.title,
        discountType: voucher.discountType,
        discountValue: voucher.discountValue
      },
      orderValue,
      discount,
      finalPrice: orderValue - discount
    }));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Tạo voucher mới (Admin only)
exports.createVoucher = async (req, res) => {
  try {
    const voucherData = req.body;
    voucherData.voucherId = `VCH${Date.now()}`;

    const voucher = await Voucher.create(voucherData);

    res.status(201).json(successResponse('Tạo voucher thành công', voucher));
  } catch (error) {
    errorHandler(res, error);
  }
};

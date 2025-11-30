// const Voucher = require('../models/Voucher');

// // @desc    Get all vouchers
// // @route   GET /api/vouchers
// // @access  Public
// const getVouchers = async (req, res) => {
//   try {
//     const { page = 1, limit = 10, isActive } = req.query;
    
//     let filter = {};
//     if (isActive !== undefined) filter.isActive = isActive === 'true';
    
//     // Only show active vouchers to public
//     if (req.user?.role !== 'admin') {
//       filter.isActive = true;
//       filter.expiryDate = { $gte: new Date() };
//     }

//     const vouchers = await Voucher.find(filter)
//       .limit(limit * 1)
//       .skip((page - 1) * limit)
//       .sort({ createdAt: -1 });

//     const total = await Voucher.countDocuments(filter);

//     res.json({
//       vouchers,
//       totalPages: Math.ceil(total / limit),
//       currentPage: page,
//       total
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get voucher by ID
// // @route   GET /api/vouchers/:id
// // @access  Public
// const getVoucherById = async (req, res) => {
//   try {
//     const voucher = await Voucher.findOne({ voucherId: req.params.id });

//     if (!voucher) {
//       return res.status(404).json({ message: 'Voucher not found' });
//     }

//     // Check if voucher is still valid
//     if (!voucher.isActive || voucher.expiryDate < new Date()) {
//       return res.status(400).json({ message: 'Voucher is expired or inactive' });
//     }

//     res.json(voucher);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Create new voucher
// // @route   POST /api/vouchers
// // @access  Private (Admin only)
// const createVoucher = async (req, res) => {
//   try {
//     const {
//       code,
//       title,
//       description,
//       discountType,
//       discountValue,
//       minOrderValue,
//       maxDiscountAmount,
//       usageLimit,
//       expiryDate
//     } = req.body;

//     // Check if voucher code already exists
//     const existingVoucher = await Voucher.findOne({ code });
//     if (existingVoucher) {
//       return res.status(400).json({ message: 'Voucher code already exists' });
//     }

//     const voucherId = 'v_' + Date.now().toString().slice(-6);
    
//     const voucher = await Voucher.create({
//       voucherId,
//       code,
//       title,
//       description,
//       discountType,
//       discountValue,
//       minOrderValue,
//       maxDiscountAmount,
//       usageLimit,
//       expiryDate
//     });
    
//     res.status(201).json(voucher);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Update voucher
// // @route   PUT /api/vouchers/:id
// // @access  Private (Admin only)
// const updateVoucher = async (req, res) => {
//   try {
//     const voucher = await Voucher.findOne({ voucherId: req.params.id });
    
//     if (!voucher) {
//       return res.status(404).json({ message: 'Voucher not found' });
//     }

//     const updates = req.body;
//     Object.keys(updates).forEach(key => {
//       voucher[key] = updates[key];
//     });
    
//     await voucher.save();
//     res.json(voucher);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Delete voucher
// // @route   DELETE /api/vouchers/:id
// // @access  Private (Admin only)
// const deleteVoucher = async (req, res) => {
//   try {
//     const voucher = await Voucher.findOne({ voucherId: req.params.id });
    
//     if (!voucher) {
//       return res.status(404).json({ message: 'Voucher not found' });
//     }

//     await Voucher.deleteOne({ voucherId: req.params.id });
//     res.json({ message: 'Voucher deleted successfully' });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Validate voucher code
// // @route   POST /api/vouchers/validate
// // @access  Public
// const validateVoucher = async (req, res) => {
//   try {
//     const { code, orderValue } = req.body;
    
//     const voucher = await Voucher.findOne({ code });
    
//     if (!voucher) {
//       return res.status(404).json({ 
//         valid: false, 
//         message: 'Voucher code not found' 
//       });
//     }

//     // Check if voucher is active
//     if (!voucher.isActive) {
//       return res.status(400).json({ 
//         valid: false, 
//         message: 'Voucher is inactive' 
//       });
//     }

//     // Check if voucher is expired
//     if (voucher.expiryDate < new Date()) {
//       return res.status(400).json({ 
//         valid: false, 
//         message: 'Voucher has expired' 
//       });
//     }

//     // Check usage limit
//     if (voucher.usageLimit && voucher.usedCount >= voucher.usageLimit) {
//       return res.status(400).json({ 
//         valid: false, 
//         message: 'Voucher usage limit reached' 
//       });
//     }

//     // Check minimum order value
//     if (voucher.minOrderValue && orderValue < voucher.minOrderValue) {
//       return res.status(400).json({ 
//         valid: false, 
//         message: `Minimum order value of $${voucher.minOrderValue} required` 
//       });
//     }

//     // Calculate discount
//     let discountAmount = 0;
//     if (voucher.discountType === 'percentage') {
//       discountAmount = (orderValue * voucher.discountValue) / 100;
//       if (voucher.maxDiscountAmount) {
//         discountAmount = Math.min(discountAmount, voucher.maxDiscountAmount);
//       }
//     } else {
//       discountAmount = voucher.discountValue;
//     }

//     res.json({
//       valid: true,
//       voucher: {
//         voucherId: voucher.voucherId,
//         code: voucher.code,
//         title: voucher.title,
//         discountAmount
//       }
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   getVouchers,
//   getVoucherById,
//   createVoucher,
//   updateVoucher,
//   deleteVoucher,
//   validateVoucher
// };
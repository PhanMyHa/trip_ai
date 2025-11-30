// const express = require('express');
// const {
//   getVouchers,
//   getVoucherById,
//   createVoucher,
//   updateVoucher,
//   deleteVoucher,
//   validateVoucher
// } = require('../controllers/vouchersController');
// const { protect, authorize } = require('../middleware/auth');

// const router = express.Router();

// // Public routes
// router.get('/', getVouchers);
// router.get('/:id', getVoucherById);
// router.post('/validate', validateVoucher);

// // Protected routes (Admin only)
// router.post('/', protect, authorize('admin'), createVoucher);
// router.put('/:id', protect, authorize('admin'), updateVoucher);
// router.delete('/:id', protect, authorize('admin'), deleteVoucher);

// module.exports = router;
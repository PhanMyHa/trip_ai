const express = require('express');
const router = express.Router();
const voucherController = require('../controllers/voucherController');
const auth = require('../middleware/auth');

// Public routes
router.get('/', voucherController.getVouchers);
router.get('/:code', voucherController.getVoucherByCode);
router.post('/apply', voucherController.applyVoucher);

// Admin routes
router.post('/', auth, voucherController.createVoucher);

module.exports = router;

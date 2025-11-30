// const express = require('express');
// const {
//   getServices,
//   getServiceById,
//   createService
// } = require('../controllers/servicesController'); // Đổi từ reviewsController thành servicesController
// const { protect, authorize } = require('../middleware/auth');

// const router = express.Router();

// router.route('/')
//   .get(getServices)
//   .post(protect, authorize('provider', 'admin'), createService);

// router.get('/:id', getServiceById);

// module.exports = router;
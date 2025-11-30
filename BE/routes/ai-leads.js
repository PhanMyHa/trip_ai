const express = require('express');
const {
  generateAILead,
  getAILeads,
  updateLeadStatus
} = require('../controllers/ai-leadsController'); // Import từ ai-leadsController
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// Provider routes
router.get('/', protect, authorize('provider'), getAILeads);
router.put('/:id/status', protect, authorize('provider'), updateLeadStatus);

// Admin routes  
router.post('/generate', protect, authorize('admin'), generateAILead);

module.exports = router;
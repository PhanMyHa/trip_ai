// const AiLead = require('../models/AiLead');
// const User = require('../models/User');
// const Service = require('../models/Service');

// // @desc    Generate AI leads for providers
// // @route   POST /api/ai-leads/generate
// // @access  Private (Admin only)
// const generateAILead = async (req, res) => {
//   try {
//     // Get all travellers and providers
//     const travellers = await User.find({ role: 'traveller', isActive: true });
//     const providers = await User.find({ role: 'provider', isActive: true });
    
//     const leads = [];

//     for (const traveller of travellers) {
//       for (const provider of providers) {
//         // Get provider's services
//         const services = await Service.find({ 
//           providerId: provider.userId, 
//           isActive: true 
//         });
        
//         if (services.length === 0) continue;

//         // Calculate match score based on interests and budget
//         let matchScore = 0;
//         const userInterests = traveller.interests || [];
//         const serviceCategories = [...new Set(services.map(s => s.category.toLowerCase()))];
        
//         // Interest matching
//         const matchingInterests = userInterests.filter(interest => 
//           serviceCategories.some(cat => 
//             cat.includes(interest.toLowerCase()) || 
//             interest.toLowerCase().includes(cat)
//           )
//         );
//         matchScore += (matchingInterests.length / Math.max(userInterests.length, 1)) * 50;

//         // Budget matching
//         const avgServicePrice = services.reduce((sum, s) => sum + s.price, 0) / services.length;
//         if (traveller.budgetRange === 'Thấp' && avgServicePrice < 100000) matchScore += 25;
//         else if (traveller.budgetRange === 'Trung bình' && avgServicePrice >= 100000 && avgServicePrice <= 500000) matchScore += 25;
//         else if (traveller.budgetRange === 'Cao' && avgServicePrice > 500000) matchScore += 25;

//         // Random factor
//         matchScore += Math.random() * 25;

//         if (matchScore >= 30) { // Only create leads with decent match score
//           const leadId = 'lead_' + Date.now().toString().slice(-6) + '_' + Math.random().toString(36).substring(2, 5);
          
//           const lead = {
//             leadId,
//             userId: traveller.userId,
//             providerId: provider.userId,
//             matchScore: Math.round(matchScore),
//             userProfile: {
//               interests: traveller.interests || [],
//               budgetRange: traveller.budgetRange || 'Trung bình',
//               preferredDestinations: [] // Can be enhanced
//             },
//             providerServices: services.map(s => s.serviceId),
//             aiRecommendation: `Khách hàng ${traveller.name} có sở thích phù hợp với dịch vụ của bạn. Tỷ lệ phù hợp: ${Math.round(matchScore)}%`
//           };
          
//           leads.push(lead);
//         }
//       }
//     }

//     // Save leads to database
//     if (leads.length > 0) {
//       await AiLead.insertMany(leads);
//     }

//     res.json({
//       message: `Generated ${leads.length} AI leads successfully`,
//       leads: leads.length
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get AI leads for provider
// // @route   GET /api/ai-leads
// // @access  Private (Provider only)
// const getAILeads = async (req, res) => {
//   try {
//     const { page = 1, limit = 10, status } = req.query;
    
//     let filter = { providerId: req.user.userId };
//     if (status) filter.status = status;

//     const leads = await AiLead.find(filter)
//       .populate('userId', 'name email avatarUrl interests budgetRange')
//       .limit(limit * 1)
//       .skip((page - 1) * limit)
//       .sort({ matchScore: -1, createdAt: -1 });

//     const total = await AiLead.countDocuments(filter);

//     res.json({
//       leads,
//       totalPages: Math.ceil(total / limit),
//       currentPage: page,
//       total
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Update lead status
// // @route   PUT /api/ai-leads/:id/status
// // @access  Private (Provider only)
// const updateLeadStatus = async (req, res) => {
//   try {
//     const { status } = req.body;
    
//     const lead = await AiLead.findOne({ 
//       leadId: req.params.id,
//       providerId: req.user.userId 
//     });
    
//     if (!lead) {
//       return res.status(404).json({ message: 'Lead not found' });
//     }

//     lead.status = status;
//     await lead.save();

//     res.json(lead);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   generateAILead,
//   getAILeads,
//   updateLeadStatus
// };
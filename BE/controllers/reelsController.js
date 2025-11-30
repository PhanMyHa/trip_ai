// const Reel = require('../models/Reel');
// const User = require('../models/User');

// // @desc    Get all reels
// // @route   GET /api/reels
// // @access  Public
// const getReels = async (req, res) => {
//   try {
//     const { page = 1, limit = 10, providerId } = req.query;
    
//     let filter = {};
//     if (providerId) filter.providerId = providerId;

//     const reels = await Reel.find(filter)
//       .populate('providerId', 'name avatarUrl')
//       .limit(limit * 1)
//       .skip((page - 1) * limit)
//       .sort({ createdAt: -1 });

//     const total = await Reel.countDocuments(filter);

//     res.json({
//       reels,
//       totalPages: Math.ceil(total / limit),
//       currentPage: page,
//       total
//     });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Get reel by ID
// // @route   GET /api/reels/:id
// // @access  Public
// const getReelById = async (req, res) => {
//   try {
//     const reel = await Reel.findOne({ reelId: req.params.id })
//       .populate('providerId', 'name avatarUrl contactPhone');

//     if (!reel) {
//       return res.status(404).json({ message: 'Reel not found' });
//     }

//     res.json(reel);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Create new reel
// // @route   POST /api/reels
// // @access  Private (Provider/Admin only)
// const createReel = async (req, res) => {
//   try {
//     const { title, description, videoUrl, thumbnailUrl, tags } = req.body;
//     const providerId = req.user.userId;

//     const reelId = 'reel_' + Date.now().toString().slice(-6);
    
//     const reel = await Reel.create({
//       reelId,
//       providerId,
//       title,
//       description,
//       videoUrl,
//       thumbnailUrl,
//       tags: tags || []
//     });

//     await reel.populate('providerId', 'name avatarUrl');
    
//     res.status(201).json(reel);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Update reel
// // @route   PUT /api/reels/:id
// // @access  Private
// const updateReel = async (req, res) => {
//   try {
//     const reel = await Reel.findOne({ reelId: req.params.id });
    
//     if (!reel) {
//       return res.status(404).json({ message: 'Reel not found' });
//     }

//     // Only reel owner or admin can update
//     if (reel.providerId.toString() !== req.user.userId && req.user.role !== 'admin') {
//       return res.status(403).json({ message: 'Not authorized to update this reel' });
//     }

//     const { title, description, videoUrl, thumbnailUrl, tags } = req.body;
    
//     reel.title = title || reel.title;
//     reel.description = description || reel.description;
//     reel.videoUrl = videoUrl || reel.videoUrl;
//     reel.thumbnailUrl = thumbnailUrl || reel.thumbnailUrl;
//     reel.tags = tags || reel.tags;
    
//     await reel.save();
//     res.json(reel);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // @desc    Delete reel
// // @route   DELETE /api/reels/:id
// // @access  Private
// const deleteReel = async (req, res) => {
//   try {
//     const reel = await Reel.findOne({ reelId: req.params.id });
    
//     if (!reel) {
//       return res.status(404).json({ message: 'Reel not found' });
//     }

//     // Only reel owner or admin can delete
//     if (reel.providerId.toString() !== req.user.userId && req.user.role !== 'admin') {
//       return res.status(403).json({ message: 'Not authorized to delete this reel' });
//     }

//     await Reel.deleteOne({ reelId: req.params.id });
//     res.json({ message: 'Reel deleted successfully' });
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// module.exports = {
//   getReels,
//   getReelById,
//   createReel,
//   updateReel,
//   deleteReel
// };
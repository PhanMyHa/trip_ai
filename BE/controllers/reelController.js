const Reel = require('../models/Reel');
const errorHandler = require('../utils/errorHandler');
const successResponse = require('../utils/response');

// Get all reels (feed)
exports.getReels = async (req, res) => {
  try {
    const { limit = 20, skip = 0 } = req.query;

    const reels = await Reel.find()
      .populate('userId', 'name avatarUrl')
      .populate('serviceId', 'title location')
      .sort({ createdAt: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    res.json(successResponse('Lấy danh sách reels thành công', reels));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Get reel by ID
exports.getReelById = async (req, res) => {
  try {
    const { id } = req.params;

    const reel = await Reel.findById(id)
      .populate('userId', 'name avatarUrl bio')
      .populate('serviceId', 'title location price images');

    if (!reel) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy reel'
      });
    }

    res.json(successResponse('Lấy chi tiết reel thành công', reel));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Create reel
exports.createReel = async (req, res) => {
  try {
    const userId = req.user.id;
    const { serviceId, videoUrl, caption, hashtags } = req.body;

    const reel = await Reel.create({
      reelId: `REEL${Date.now()}`,
      userId,
      serviceId,
      videoUrl,
      caption,
      hashtags: hashtags || []
    });

    await reel.populate('userId', 'name avatarUrl');
    await reel.populate('serviceId', 'title location');

    res.status(201).json(successResponse('Tạo reel thành công', reel));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Like/Unlike reel
exports.toggleLikeReel = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const reel = await Reel.findById(id);
    if (!reel) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy reel'
      });
    }

    const likedIndex = reel.likedBy.indexOf(userId);
    if (likedIndex > -1) {
      // Unlike
      reel.likedBy.splice(likedIndex, 1);
      reel.likes = Math.max(0, reel.likes - 1);
    } else {
      // Like
      reel.likedBy.push(userId);
      reel.likes += 1;
    }

    await reel.save();

    res.json(successResponse('Cập nhật like thành công', {
      isLiked: likedIndex === -1,
      likes: reel.likes
    }));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Increment view count
exports.incrementView = async (req, res) => {
  try {
    const { id } = req.params;

    const reel = await Reel.findByIdAndUpdate(
      id,
      { $inc: { views: 1 } },
      { new: true }
    );

    if (!reel) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy reel'
      });
    }

    res.json(successResponse('Cập nhật view thành công', { views: reel.views }));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Increment share count
exports.incrementShare = async (req, res) => {
  try {
    const { id } = req.params;

    const reel = await Reel.findByIdAndUpdate(
      id,
      { $inc: { shares: 1 } },
      { new: true }
    );

    if (!reel) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy reel'
      });
    }

    res.json(successResponse('Cập nhật share thành công', { shares: reel.shares }));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Get reels by service
exports.getReelsByService = async (req, res) => {
  try {
    const { serviceId } = req.params;

    const reels = await Reel.find({ serviceId })
      .populate('userId', 'name avatarUrl')
      .sort({ createdAt: -1 });

    res.json(successResponse('Lấy danh sách reels theo service thành công', reels));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Get reels by user
exports.getReelsByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const reels = await Reel.find({ userId })
      .populate('serviceId', 'title location')
      .sort({ createdAt: -1 });

    res.json(successResponse('Lấy danh sách reels theo user thành công', reels));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Delete reel
exports.deleteReel = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const reel = await Reel.findOne({ _id: id, userId });

    if (!reel) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy reel hoặc bạn không có quyền xóa'
      });
    }

    await reel.deleteOne();

    res.json(successResponse('Xóa reel thành công'));
  } catch (error) {
    errorHandler(res, error);
  }
};

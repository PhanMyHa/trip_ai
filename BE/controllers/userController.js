const User = require('../models/User');
const Booking = require('../models/Booking');

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Error in getUserProfile:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
exports.updateUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Update fields
    user.name = req.body.name || user.name;
    user.bio = req.body.bio || user.bio;
    user.interests = req.body.interests || user.interests;
    user.budgetRange = req.body.budgetRange || user.budgetRange;
    user.contactPhone = req.body.contactPhone || user.contactPhone;
    
    if (req.body.avatarUrl) {
      user.avatarUrl = req.body.avatarUrl;
    }
    
    const updatedUser = await user.save();
    
    res.json({
      _id: updatedUser._id,
      userId: updatedUser.userId,
      name: updatedUser.name,
      email: updatedUser.email,
      role: updatedUser.role,
      avatarUrl: updatedUser.avatarUrl,
      bio: updatedUser.bio,
      interests: updatedUser.interests,
      budgetRange: updatedUser.budgetRange,
      contactPhone: updatedUser.contactPhone
    });
  } catch (error) {
    console.error('Error in updateUserProfile:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user booking history
// @route   GET /api/users/bookings
// @access  Private
exports.getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.id })
      .populate('serviceId', 'title category images location price')
      .sort({ createdAt: -1 });
    
    res.json(bookings);
  } catch (error) {
    console.error('Error in getUserBookings:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user favorites
// @route   GET /api/users/favorites
// @access  Private
exports.getUserFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate({
      path: 'favorites',
      model: 'Service',
      select: 'title category images location price rating reviewCount'
    });
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json(user.favorites || []);
  } catch (error) {
    console.error('Error in getUserFavorites:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user by ID (public profile)
// @route   GET /api/users/:id
// @access  Public
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password -email -contactPhone');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Return public profile info only
    res.json({
      _id: user._id,
      userId: user.userId,
      name: user.name,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      interests: user.interests,
      role: user.role,
      createdAt: user.createdAt
    });
  } catch (error) {
    console.error('Error in getUserById:', error);
    res.status(500).json({ message: error.message });
  }
};

// @desc    Change password
// @route   PUT /api/users/password
// @access  Private
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Check current password
    const isMatch = await user.matchPassword(currentPassword);
    
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }
    
    // Update password
    user.password = newPassword;
    await user.save();
    
    res.json({ message: 'Password updated successfully' });
  } catch (error) {
    console.error('Error in changePassword:', error);
    res.status(500).json({ message: error.message });
  }
};

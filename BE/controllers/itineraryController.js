const Itinerary = require('../models/Itinerary');
const errorHandler = require('../utils/errorHandler');
const successResponse = require('../utils/response');

// Lấy danh sách itinerary của user
exports.getUserItineraries = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    const filter = { userId };
    if (status) filter.status = status;

    const itineraries = await Itinerary.find(filter)
      .sort({ createdAt: -1 })
      .select('-__v');

    res.json(successResponse('Lấy danh sách lịch trình thành công', itineraries));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Lấy chi tiết itinerary
exports.getItineraryById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const itinerary = await Itinerary.findById(id);

    if (!itinerary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch trình'
      });
    }

    res.json(successResponse('Lấy chi tiết lịch trình thành công', itinerary));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Tạo itinerary mới (từ AI)
exports.createItinerary = async (req, res) => {
  try {
    const userId = req.user.id;
    const itineraryData = {
      ...req.body,
      userId,
      itineraryId: `ITN${Date.now()}`
    };

    const itinerary = await Itinerary.create(itineraryData);

    res.status(201).json(successResponse('Tạo lịch trình thành công', itinerary));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Cập nhật itinerary
exports.updateItinerary = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const itinerary = await Itinerary.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    );

    if (!itinerary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch trình'
      });
    }

    res.json(successResponse('Cập nhật lịch trình thành công', itinerary));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Lưu/bỏ lưu itinerary
exports.toggleSaveItinerary = async (req, res) => {
  try {
    const { id } = req.params;
    
    const itinerary = await Itinerary.findById(id);

    if (!itinerary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch trình'
      });
    }

    itinerary.isSaved = !itinerary.isSaved;
    await itinerary.save();

    res.json(successResponse(
      itinerary.isSaved ? 'Đã lưu lịch trình' : 'Đã bỏ lưu lịch trình', 
      itinerary
    ));
  } catch (error) {
    errorHandler(res, error);
  }
};

// Xóa itinerary
exports.deleteItinerary = async (req, res) => {
  try {
    const { id } = req.params;

    const itinerary = await Itinerary.findByIdAndDelete(id);

    if (!itinerary) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch trình'
      });
    }

    res.json(successResponse('Xóa lịch trình thành công'));
  } catch (error) {
    errorHandler(res, error);
  }
};

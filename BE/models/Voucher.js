const mongoose = require('mongoose');

const voucherSchema = new mongoose.Schema({
  voucherId: {
    type: String,
    unique: true,
    required: true
  },
  code: {
    type: String,
    unique: true,
    required: true,
    uppercase: true,
    trim: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  discountValue: {
    type: Number,
    required: true,
    min: 0
  },
  discountType: {
    type: String,
    enum: ['percentage', 'fixed'],
    required: true
  },
  minOrderValue: {
    type: Number,
    default: 0
  },
  maxDiscountAmount: {
    type: Number
  },
  expiryDate: {
    type: Date,
    required: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  applicableCategory: {
    type: String,
    enum: ['hotel', 'tour', 'flight', 'restaurant', 'all'],
    default: 'all'
  },
  usageLimit: {
    type: Number,
    default: null
  },
  usedCount: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

voucherSchema.index({ code: 1 });
voucherSchema.index({ expiryDate: 1, isActive: 1 });

voucherSchema.methods.isValid = function() {
  const now = new Date();
  return this.isActive && 
         this.expiryDate > now && 
         (this.usageLimit === null || this.usedCount < this.usageLimit);
};

voucherSchema.methods.calculateDiscount = function(orderValue) {
  if (!this.isValid()) return 0;
  if (orderValue < this.minOrderValue) return 0;

  let discount = 0;
  if (this.discountType === 'percentage') {
    discount = (orderValue * this.discountValue) / 100;
    if (this.maxDiscountAmount && discount > this.maxDiscountAmount) {
      discount = this.maxDiscountAmount;
    }
  } else {
    discount = this.discountValue;
  }
  return discount;
};

module.exports = mongoose.model('Voucher', voucherSchema);

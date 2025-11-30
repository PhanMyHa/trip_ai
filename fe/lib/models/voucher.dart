import 'package:flutter/material.dart';

class Voucher {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountValue;
  final String discountType; // 'percentage' or 'fixed'
  final double? minOrderValue;
  final DateTime expiryDate;
  final bool isActive;
  final String? applicableCategory;

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.discountType,
    required this.expiryDate,
    this.minOrderValue,
    this.isActive = true,
    this.applicableCategory,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 'percentage',
      expiryDate: DateTime.parse(
        json['expiryDate'] ?? DateTime.now().toIso8601String(),
      ),
      minOrderValue: json['minOrderValue']?.toDouble(),
      isActive: json['isActive'] ?? true,
      applicableCategory: json['applicableCategory'],
    );
  }

  Color get color {
    switch (applicableCategory?.toLowerCase()) {
      case 'hotel':
        return Colors.blue;
      case 'tour':
        return Colors.green;
      case 'flight':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  String get discountText {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}%';
    } else {
      return '${discountValue.toStringAsFixed(0)}đ';
    }
  }
}

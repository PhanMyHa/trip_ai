import 'package:fe/models/booking.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Nhận Đặt Chỗ'),
        automaticallyImplyLeading: false, // Ngăn quay lại Checkout
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: AppColors.successGreen,
              ),
              const SizedBox(height: 20),
              const Text(
                'Đặt chỗ thành công!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Mã đặt chỗ của bạn là: ${booking.bookingId}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              _buildSummaryCard(dateFormat),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.list_alt_rounded,
                    color: AppColors.textLight,
                  ),
                  label: const Text('Quản lý Đặt chỗ'),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/my_bookings',
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Trở về Trang chủ',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(DateFormat dateFormat) {
    final service = booking.service;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service?.category ?? 'Dịch vụ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const Divider(height: 15),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.hotel_rounded,
                color: AppColors.secondaryOrange,
              ),
              title: Text(
                service?.title ?? 'Đang tải...',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Ngày: ${dateFormat.format(booking.checkInDate)} - ${dateFormat.format(booking.checkOutDate)}\n'
                'Số khách: ${booking.numberOfGuests}',
              ),
            ),
            const Divider(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền đã thanh toán:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${NumberFormat('#,###', 'vi_VN').format(booking.totalPrice.toInt())}đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

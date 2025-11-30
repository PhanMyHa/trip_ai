import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


// Mock thông tin đặt chỗ
class BookingSummary {
  final String serviceType;
  final String title;
  final String date;
  final int totalAmount;
  final int discount;

  BookingSummary({
    required this.serviceType,
    required this.title,
    required this.date,
    required this.totalAmount,
    this.discount = 150000,
  });
}

final mockSummary = BookingSummary(
  serviceType: 'Khách sạn',
  title: 'Khách sạn Đồi Thông - Phòng Deluxe',
  date: '20/12/2024 - 22/12/2024',
  totalAmount: 3600000,
);

class CheckoutScreen extends StatelessWidget {
  final BookingSummary summary;

  const CheckoutScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh Toán Đặt Chỗ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingSummaryCard(),
            const SizedBox(height: 30),
            _buildPaymentMethodSection(),
            const SizedBox(height: 30),
            _buildVoucherSection(),
            const SizedBox(height: 30),
            _buildPriceDetails(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildPaymentBar(context),
    );
  }

  // --- Tóm tắt Đặt chỗ ---
  Widget _buildBookingSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.serviceType,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)),
            const Divider(height: 15),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.hotel_rounded, color: AppColors.secondaryOrange),
              title: Text(summary.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Ngày: ${summary.date}'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Phương thức Thanh toán ---
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phương thức Thanh toán',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildPaymentOption(
            'Ví điện tử (Momo/ZaloPay)', Icons.qr_code_rounded, true),
        _buildPaymentOption('Thẻ Tín dụng/Ghi nợ', Icons.credit_card_rounded, false),
        _buildPaymentOption('Chuyển khoản Ngân hàng', Icons.account_balance_rounded, false),
      ],
    );
  }

  Widget _buildPaymentOption(String label, IconData icon, bool isSelected) {
    return RadioListTile<String>(
      value: label,
      groupValue: isSelected ? label : null,
      onChanged: (value) {
        // Xử lý chọn phương thức thanh toán
      },
      title: Text(label),
      secondary: Icon(icon, color: isSelected ? AppColors.primaryBlue : Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: AppColors.secondaryOrange,
    );
  }

  // --- Voucher ---
  Widget _buildVoucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mã Giảm Giá & Ưu Đãi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextFormField(
          initialValue: 'TRAVELAI20',
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Voucher đã áp dụng',
            prefixIcon: const Icon(Icons.local_offer_rounded, color: AppColors.secondaryOrange),
            suffixIcon: TextButton(
              onPressed: () {},
              child: const Text('Thay đổi'),
            ),
          ),
        ),
      ],
    );
  }

  // --- Chi tiết Giá ---
  Widget _buildPriceDetails() {
    final subtotal = summary.totalAmount;
    final discount = summary.discount;
    final tax = 100000;
    final finalTotal = subtotal - discount + tax;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceRow('Tổng tiền dịch vụ', subtotal, false),
            _buildPriceRow('Mã giảm giá (TRAVELAI20)', -discount, true),
            _buildPriceRow('Phí dịch vụ & Thuế', tax, false),
            const Divider(height: 25),
            _buildPriceRow('TỔNG THANH TOÁN', finalTotal, false, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount, bool isDiscount,
      {bool isTotal = false}) {
    final color = isTotal ? AppColors.errorRed : AppColors.textDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? color : Colors.grey.shade700)),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                color: color,
                fontSize: isTotal ? 18 : 16),
          ),
        ],
      ),
    );
  }

  // --- Thanh Thanh toán cố định ---
  Widget _buildPaymentBar(BuildContext context) {
    final finalTotal = mockSummary.totalAmount - mockSummary.discount + 100000;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // CẬP NHẬT: Chuyển sang màn hình xác nhận
            Navigator.pushNamed(context, '/booking_confirmation', arguments: summary);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'THANH TOÁN ${finalTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight),
          ),
        ),
      ),
    );
  }
}
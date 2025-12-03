import 'package:fe/models/booking.dart';
import 'package:fe/models/service.dart';
import 'package:fe/screens/app/booking_confirm_screen.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final Service service;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final String? specialRequests;

  const CheckoutScreen({
    super.key,
    required this.service,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    this.specialRequests,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _voucherController = TextEditingController();
  bool _isProcessing = false;
  String? _appliedVoucherCode;
  double _discountAmount = 0;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  int get _numberOfDays {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  double get _subtotal {
    if (widget.service.category.contains('Tour')) {
      return widget.service.price * widget.numberOfGuests;
    }
    return widget.service.price * widget.numberOfGuests * _numberOfDays;
  }

  double get _tax {
    return _subtotal * 0.1;
  }

  double get _finalTotal {
    return _subtotal - _discountAmount + _tax;
  }

  Future<void> _applyVoucher() async {
    if (_voucherController.text.trim().isEmpty) return;

    try {
      final result = await ApiService.applyVoucher(
        _voucherController.text.trim(),
        _subtotal,
      );
      if (result != null && mounted) {
        setState(() {
          _appliedVoucherCode = _voucherController.text.trim();
          _discountAmount = result['discount']?.toDouble() ?? 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Áp dụng voucher thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final bookingData = await ApiService.createBooking(
        serviceId: widget.service.id,
        checkInDate: widget.checkInDate,
        checkOutDate: widget.checkOutDate,
        numberOfGuests: widget.numberOfGuests,
        specialRequests: widget.specialRequests,
        voucherCode: _appliedVoucherCode,
      );

      if (bookingData != null && mounted) {
        final booking = Booking.fromJson(bookingData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(booking: booking),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đặt chỗ: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh Toán Đặt Chỗ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingSummaryCard(dateFormat),
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
  Widget _buildBookingSummaryCard(DateFormat dateFormat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.service.category,
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
                widget.service.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Ngày: ${dateFormat.format(widget.checkInDate)} - ${dateFormat.format(widget.checkOutDate)}\n'
                'Số khách: ${widget.numberOfGuests}',
              ),
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
        const Text(
          'Phương thức Thanh toán',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildPaymentOption(
          'Ví điện tử (Momo/ZaloPay)',
          Icons.qr_code_rounded,
          true,
        ),
        _buildPaymentOption(
          'Thẻ Tín dụng/Ghi nợ',
          Icons.credit_card_rounded,
          false,
        ),
        _buildPaymentOption(
          'Chuyển khoản Ngân hàng',
          Icons.account_balance_rounded,
          false,
        ),
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
      secondary: Icon(
        icon,
        color: isSelected ? AppColors.primaryBlue : Colors.grey,
      ),
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
        const Text(
          'Mã Giảm Giá & Ưu Đãi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _voucherController,
                decoration: InputDecoration(
                  labelText: _appliedVoucherCode == null
                      ? 'Nhập mã voucher'
                      : 'Voucher đã áp dụng',
                  prefixIcon: const Icon(
                    Icons.local_offer_rounded,
                    color: AppColors.secondaryOrange,
                  ),
                ),
                enabled: _appliedVoucherCode == null,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _appliedVoucherCode == null
                  ? _applyVoucher
                  : () {
                      setState(() {
                        _appliedVoucherCode = null;
                        _discountAmount = 0;
                        _voucherController.clear();
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _appliedVoucherCode == null
                    ? AppColors.primaryBlue
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              child: Text(_appliedVoucherCode == null ? 'Áp dụng' : 'Hủy'),
            ),
          ],
        ),
      ],
    );
  }

  // --- Chi tiết Giá ---
  Widget _buildPriceDetails() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceRow('Tổng tiền dịch vụ', _subtotal, false),
            if (_discountAmount > 0)
              _buildPriceRow(
                'Mã giảm giá ($_appliedVoucherCode)',
                _discountAmount,
                true,
              ),
            _buildPriceRow('Phí dịch vụ & Thuế (10%)', _tax, false),
            const Divider(height: 25),
            _buildPriceRow(
              'TỔNG THANH TOÁN',
              _finalTotal,
              false,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    bool isDiscount, {
    bool isTotal = false,
  }) {
    final color = isTotal ? AppColors.errorRed : AppColors.textDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? color : Colors.grey.shade700,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${NumberFormat('#,###', 'vi_VN').format(amount.toInt())}đ',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: color,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  // --- Thanh Thanh toán cố định ---
  Widget _buildPaymentBar(BuildContext context) {
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
          onPressed: _isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'THANH TOÁN ${NumberFormat('#,###', 'vi_VN').format(_finalTotal.toInt())}đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
        ),
      ),
    );
  }
}

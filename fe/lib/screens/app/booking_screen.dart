import 'package:fe/screens/app/checkout_screen.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


class BookingScreen extends StatefulWidget {
  final String initialTab;
  final String? placeName;

  const BookingScreen({super.key, this.initialTab = 'Hotel', this.placeName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Thiết lập tab ban đầu
    if (widget.initialTab == 'Flight') {
      _tabController.index = 1;
    } else if (widget.initialTab == 'Tour') {
      _tabController.index = 2;
    } else {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt Dịch Vụ'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondaryOrange,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.hotel_rounded), text: 'Khách sạn'),
            Tab(icon: Icon(Icons.flight_takeoff_rounded), text: 'Vé máy bay'),
            Tab(icon: Icon(Icons.tour_rounded), text: 'Tour'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHotelBookingForm(),
          _buildFlightBookingForm(),
          _buildTourBookingForm(),
        ],
      ),
    );
  }

  // --- Form Đặt Khách sạn ---
  Widget _buildHotelBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: widget.placeName ?? 'Khách sạn Đồi Thông',
            decoration: const InputDecoration(
              labelText: 'Địa điểm/Khách sạn',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _buildDateField('Ngày Check-in', Icons.calendar_today_rounded, '20/12/2024'),
          const SizedBox(height: 16),
          _buildDateField('Ngày Check-out', Icons.calendar_today_rounded, '22/12/2024'),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: '2 Người lớn, 1 Phòng',
            decoration: const InputDecoration(
              labelText: 'Số lượng khách & phòng',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 30),
          _buildBookingButton(
              context, 'Đặt và Thanh toán', mockSummary), // CẬP NHẬT: truyền mockSummary
        ],
      ),
    );
  }

  // --- Form Đặt Vé máy bay ---
  Widget _buildFlightBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: 'TP.HCM (SGN)',
            decoration: const InputDecoration(
              labelText: 'Điểm khởi hành',
              prefixIcon: Icon(Icons.flight_takeoff_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: 'Hà Nội (HAN)',
            decoration: const InputDecoration(
              labelText: 'Điểm đến',
              prefixIcon: Icon(Icons.flight_land_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _buildDateField('Ngày đi', Icons.calendar_today_rounded, '25/12/2024'),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: '1 Người lớn, Hạng Phổ thông',
            decoration: const InputDecoration(
              labelText: 'Hành khách & Hạng vé',
              prefixIcon: Icon(Icons.group_rounded),
            ),
          ),
          const SizedBox(height: 30),
          _buildBookingButton(
              context,
              'Đặt và Thanh toán',
              BookingSummary( // CẬP NHẬT: tạo mockSummary cho Flight
                  serviceType: 'Vé máy bay',
                  title: 'TP.HCM -> Hà Nội',
                  date: '25/12/2024',
                  totalAmount: 2500000)),
        ],
      ),
    );
  }

  // --- Form Đặt Tour ---
  Widget _buildTourBookingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: 'Tour Đà Lạt 3N2Đ - Khám phá Hồ Tuyền Lâm',
            decoration: const InputDecoration(
              labelText: 'Tên Tour/Địa điểm',
              prefixIcon: Icon(Icons.tour_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _buildDateField('Ngày bắt đầu Tour', Icons.calendar_today_rounded, '01/01/2025'),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: '4 Khách',
            decoration: const InputDecoration(
              labelText: 'Số lượng khách',
              prefixIcon: Icon(Icons.group_rounded),
            ),
          ),
          const SizedBox(height: 30),
          _buildBookingButton(
              context,
              'Đặt và Thanh toán',
              BookingSummary( // CẬP NHẬT: tạo mockSummary cho Tour
                  serviceType: 'Tour',
                  title: 'Tour Đà Lạt 3N2Đ',
                  date: '01/01/2025',
                  totalAmount: 3400000)),
        ],
      ),
    );
  }

  // --- Common Widgets ---
  Widget _buildDateField(String label, IconData icon, String date) {
    return TextFormField(
      readOnly: true,
      initialValue: date,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      onTap: () async {
        // Mock Date Picker
        await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
        );
      },
    );
  }

  // Cập nhật hàm này để nhận BookingSummary và chuyển sang CheckoutScreen
  Widget _buildBookingButton(
      BuildContext context, String text, BookingSummary summary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textLight),
        label: Text(text),
        onPressed: () {
          // CHUYỂN SANG MÀN HÌNH THANH TOÁN
          Navigator.pushNamed(context, '/checkout', arguments: summary);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryOrange,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
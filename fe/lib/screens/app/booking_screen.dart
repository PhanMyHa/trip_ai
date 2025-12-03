import 'package:fe/models/service.dart';
import 'package:fe/screens/app/checkout_screen.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Service service;
  final String initialTab;

  const BookingScreen({
    super.key,
    required this.service,
    this.initialTab = 'Hotel',
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  int _numberOfGuests = 2;
  final _specialRequestsController = TextEditingController();

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
    _specialRequestsController.dispose();
    super.dispose();
  }

  int get _numberOfDays {
    return _checkOutDate.difference(_checkInDate).inDays;
  }

  double get _calculatedPrice {
    return widget.service.price * _numberOfGuests * _numberOfDays;
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate.isBefore(_checkInDate.add(const Duration(days: 1)))) {
          _checkOutDate = _checkInDate.add(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() => _checkOutDate = picked);
    }
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: widget.service.title,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Địa điểm/Khách sạn',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectCheckInDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ngày Check-in',
                prefixIcon: Icon(Icons.calendar_today_rounded),
                border: OutlineInputBorder(),
              ),
              child: Text(dateFormat.format(_checkInDate)),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectCheckOutDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ngày Check-out',
                prefixIcon: Icon(Icons.calendar_today_rounded),
                border: OutlineInputBorder(),
              ),
              child: Text(dateFormat.format(_checkOutDate)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _numberOfGuests.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số lượng khách',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            onChanged: (value) {
              final guests = int.tryParse(value);
              if (guests != null && guests > 0) {
                setState(() => _numberOfGuests = guests);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialRequestsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Yêu cầu đặc biệt (tùy chọn)',
              prefixIcon: Icon(Icons.notes_rounded),
              hintText: 'Ví dụ: Giường đôi, tầng cao, không hút thuốc...',
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: AppColors.accentLight.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Giá mỗi đêm:'),
                      Text(
                        '${NumberFormat('#,###', 'vi_VN').format(widget.service.price)}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_numberOfDays đêm × $_numberOfGuests khách'),
                      Text(
                        '${NumberFormat('#,###', 'vi_VN').format(_calculatedPrice)}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      service: widget.service,
                      checkInDate: _checkInDate,
                      checkOutDate: _checkOutDate,
                      numberOfGuests: _numberOfGuests,
                      specialRequests:
                          _specialRequestsController.text.trim().isEmpty
                          ? null
                          : _specialRequestsController.text.trim(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Đặt và Thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Form Đặt Vé máy bay ---
  Widget _buildFlightBookingForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Tính năng đặt vé máy bay đang phát triển',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  // --- Form Đặt Tour ---
  Widget _buildTourBookingForm() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: widget.service.title,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Tên Tour/Địa điểm',
              prefixIcon: Icon(Icons.tour_rounded),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectCheckInDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ngày bắt đầu Tour',
                prefixIcon: Icon(Icons.calendar_today_rounded),
                border: OutlineInputBorder(),
              ),
              child: Text(dateFormat.format(_checkInDate)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _numberOfGuests.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số lượng khách',
              prefixIcon: Icon(Icons.group_rounded),
            ),
            onChanged: (value) {
              final guests = int.tryParse(value);
              if (guests != null && guests > 0) {
                setState(() => _numberOfGuests = guests);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialRequestsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Yêu cầu đặc biệt (tùy chọn)',
              prefixIcon: Icon(Icons.notes_rounded),
              hintText: 'Ví dụ: Ăn chay, dị ứng thực phẩm...',
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: AppColors.accentLight.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Giá mỗi người:'),
                      Text(
                        '${NumberFormat('#,###', 'vi_VN').format(widget.service.price)}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_numberOfGuests khách'),
                      Text(
                        '${NumberFormat('#,###', 'vi_VN').format(widget.service.price * _numberOfGuests)}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      service: widget.service,
                      checkInDate: _checkInDate,
                      checkOutDate: _checkInDate, // Tour 1 ngày
                      numberOfGuests: _numberOfGuests,
                      specialRequests:
                          _specialRequestsController.text.trim().isEmpty
                          ? null
                          : _specialRequestsController.text.trim(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Đặt và Thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

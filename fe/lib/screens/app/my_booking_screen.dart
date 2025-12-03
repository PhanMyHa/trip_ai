import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final bookings = await ApiService.getUserBookings();
    setState(() {
      _allBookings = bookings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final upcomingCount = _allBookings
        .where((b) => b['status'] == 'pending' || b['status'] == 'confirmed')
        .length;
    final completedCount = _allBookings
        .where((b) => b['status'] == 'completed')
        .length;
    final cancelledCount = _allBookings
        .where((b) => b['status'] == 'cancelled')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn Đặt Chỗ Của Tôi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppColors.primaryBlue,
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: Colors.grey.shade600,
                    tabs: [
                      Tab(text: 'Sắp tới ($upcomingCount)'),
                      Tab(text: 'Lịch sử ($completedCount)'),
                      Tab(text: 'Đã hủy ($cancelledCount)'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBookingList(context, ['pending', 'confirmed']),
                        _buildBookingList(context, ['completed']),
                        _buildBookingList(context, ['cancelled']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<String> statusFilter) {
    final filteredList = _allBookings
        .where((b) => statusFilter.contains(b['status']))
        .toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Chưa có booking nào'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final booking = filteredList[index];
        final service = booking['serviceId'];

        // Parse dates
        final checkIn = DateTime.parse(booking['checkInDate']);
        final checkOut = DateTime.parse(booking['checkOutDate']);
        final dateStr =
            '${DateFormat('dd/MM/yyyy').format(checkIn)} - ${DateFormat('dd/MM/yyyy').format(checkOut)}';

        // Get icon and color based on category
        IconData icon = Icons.hotel_rounded;
        if (service['category'] == 'Tour') {
          icon = Icons.tour_rounded;
        } else if (service['category'] == 'Flight') {
          icon = Icons.flight_takeoff_rounded;
        } else if (service['category'] == 'Restaurant') {
          icon = Icons.restaurant_rounded;
        }

        Color statusColor = AppColors.secondaryOrange;
        String statusText = 'Đang chờ';
        if (booking['status'] == 'confirmed') {
          statusColor = AppColors.successGreen;
          statusText = 'Đã xác nhận';
        } else if (booking['status'] == 'completed') {
          statusColor = Colors.grey;
          statusText = 'Đã hoàn thành';
        } else if (booking['status'] == 'cancelled') {
          statusColor = AppColors.errorRed;
          statusText = 'Đã hủy';
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(icon, color: statusColor),
            title: Text(
              service['title'] ?? 'Dịch vụ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã: ${booking['bookingId']}'),
                Text('Ngày: $dateStr'),
                Text(
                  'Tổng: ${booking['totalPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]}.')} VNĐ',
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (booking['status'] == 'pending')
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hủy booking'),
                          content: const Text(
                            'Bạn có chắc muốn hủy booking này?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Không'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hủy booking'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        final success = await ApiService.cancelBooking(
                          booking['_id'],
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã hủy booking')),
                          );
                          _loadBookings();
                        }
                      }
                    },
                    child: const Text('Hủy >', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            onTap: () {
              // Chi tiết booking
            },
          ),
        );
      },
    );
  }
}

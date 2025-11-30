import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  final List<Map<String, dynamic>> mockBookings = const [
    {
      'id': '#928374',
      'title': 'Khách sạn Đồi Thông',
      'date': '20/12/2024 - 22/12/2024',
      'status': 'Đã xác nhận',
      'icon': Icons.hotel_rounded,
      'color': AppColors.successGreen,
    },
    {
      'id': '#882103',
      'title': 'Vé máy bay TP.HCM -> HN',
      'date': '25/12/2024',
      'status': 'Đang chờ thanh toán',
      'icon': Icons.flight_takeoff_rounded,
      'color': AppColors.secondaryOrange,
    },
    {
      'id': '#710923',
      'title': 'Tour 1 ngày khám phá Sa Pa',
      'date': '10/01/2025',
      'status': 'Đã hoàn thành',
      'icon': Icons.tour_rounded,
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn Đặt Chỗ Của Tôi'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.primaryBlue,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: const [
                Tab(text: 'Sắp tới (2)'),
                Tab(text: 'Lịch sử (5)'),
                Tab(text: 'Đã hủy (1)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookingList(context, 'confirmed'),
                  _buildBookingList(context, 'completed'),
                  _buildBookingList(context, 'cancelled'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, String filter) {
    // Giả lập filter: chỉ hiện 2 đơn đầu tiên cho tab "Sắp tới"
    final filteredList = filter == 'confirmed' ? mockBookings.take(2).toList() : mockBookings.take(1).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final booking = filteredList[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(booking['icon'] as IconData,
                color: booking['color'] as Color),
            title: Text(booking['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã: ${booking['id']}'),
                Text('Ngày: ${booking['date']}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  booking['status'] as String,
                  style: TextStyle(
                      color: booking['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                if (filter == 'confirmed')
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chuyển đến màn hình Voucher/Vé điện tử.')));
                    },
                    child: const Text('Xem vé >', style: TextStyle(fontSize: 13)),
                  )
              ],
            ),
            onTap: () {
              // Chuyển đến màn hình Ticket Detail
            },
          ),
        );
      },
    );
  }
}
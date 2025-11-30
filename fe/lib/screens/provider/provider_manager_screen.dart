import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


class ProviderManagementScreen extends StatelessWidget {
  const ProviderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Bookings, Leads, Analytics
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản Lý Đơn Đặt & Khách Hàng'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textLight,
          bottom: const TabBar(
            indicatorColor: AppColors.secondaryOrange,
            labelColor: AppColors.textLight,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Đặt chỗ'),
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Leads AI'),
              Tab(icon: Icon(Icons.analytics_rounded), text: 'Báo cáo'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookingManagementTab(),
            LeadsManagementTab(),
            AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

// --- Tab 1: Quản lý Đặt chỗ ---
class BookingManagementTab extends StatelessWidget {
  const BookingManagementTab({super.key});

  final List<Map<String, dynamic>> mockBookings = const [
    {
      'customer': 'Nguyễn Văn A',
      'service': 'Phòng Deluxe',
      'date': '20/12',
      'status': 'Chờ duyệt',
      'color': AppColors.secondaryOrange
    },
    {
      'customer': 'Trần Thị B',
      'service': 'Tour Cắm trại',
      'date': '25/12',
      'status': 'Đã xác nhận',
      'color': AppColors.successGreen
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...mockBookings.map((b) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.assignment_ind_rounded, color: AppColors.primaryBlue),
                title: Text(b['service'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Khách: ${b['customer']} - Ngày: ${b['date']}'),
                trailing: Chip(
                  label: Text(b['status'] as String, style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  backgroundColor: b['color'] as Color,
                ),
                onTap: () {
                  // Mở chi tiết Booking
                },
              ),
            )),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.archive_rounded),
            label: const Text('Xem Lịch sử Giao dịch'),
            onPressed: () {},
          ),
        )
      ],
    );
  }
}

// --- Tab 2: Leads AI (Khách hàng tiềm năng) ---
class LeadsManagementTab extends StatelessWidget {
  const LeadsManagementTab({super.key});

  final List<Map<String, dynamic>> mockLeads = const [
    {
      'name': 'Lê Văn C',
      'profile': 'Thích Núi, Cắm trại. Ngân sách TB.',
      'match': '92%',
      'action': 'Gửi voucher Cắm trại'
    },
    {
      'name': 'Phạm Thu D',
      'profile': 'Thích Nghỉ dưỡng, Lãng mạn. Ngân sách Cao.',
      'match': '85%',
      'action': 'Gửi ưu đãi phòng Deluxe'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Khách hàng tiềm năng được AI gợi ý:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 15),
        ...mockLeads.map((lead) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lead['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(
                          label: Text('Match ${lead['match']}', style: const TextStyle(color: AppColors.textLight)),
                          backgroundColor: AppColors.secondaryOrange,
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(lead['profile'] as String, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.send_rounded),
                        label: Text(lead['action'] as String),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            ))
      ],
    );
  }
}

// --- Tab 3: Analytics (Báo cáo) ---
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartCard(
              'Biểu đồ Doanh thu (Quý 4)', const Icon(Icons.show_chart, color: AppColors.primaryBlue)),
          _buildChartCard(
              'Tỷ lệ chuyển đổi (Conversion)', const Icon(Icons.trending_up_rounded, color: AppColors.secondaryOrange)),
          _buildChartCard(
              'Đánh giá trung bình', const Icon(Icons.star_half_rounded, color: AppColors.successGreen)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Icon icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            // Placeholder cho Biểu đồ
            Container(
              height: 200,
              color: Colors.grey.shade50,
              child: const Center(
                  child: Text('Placeholder Biểu đồ (Sử dụng fl_chart)',
                      style: TextStyle(color: Colors.grey))),
            )
          ],
        ),
      ),
    );
  }
}
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Nhà Cung Cấp'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textLight,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatistics(context),
            const SizedBox(height: 30),
            _buildAIMatchingSection(context),
            const SizedBox(height: 30),
            _buildManagementSection(context),
            const SizedBox(height: 30),
            _buildBookingCalendar(context),
          ],
        ),
      ),
    );
  }

  // --- Thống kê ---
  Widget _buildStatistics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê Tổng quan (Tháng 11)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(context, 'Đặt chỗ', '120', Icons.check_circle_outline, AppColors.successGreen),
            _buildStatCard(context, 'Doanh thu', '95M VNĐ', Icons.monetization_on, AppColors.secondaryOrange),
            _buildStatCard(context, 'Đánh giá', '4.7 / 5', Icons.star_rate, AppColors.primaryBlue),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  // --- AI Matching Khách hàng tiềm năng ---
  Widget _buildAIMatchingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Gợi ý Khách hàng Tiềm năng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        GradientCard(
          gradientColors: const [AppColors.secondaryOrange, AppColors.primaryBlue],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Khách hàng phù hợp nhất (90% Match)',
                style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPotentialCustomerItem('Nguyễn T. Linh', 'Thích Nghỉ dưỡng, Ngân sách Cao', '80%'),
              _buildPotentialCustomerItem('Trần Văn Bách', 'Thích Cắm trại, Ngân sách TB', '75%'),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.send, color: AppColors.textLight),
                label: const Text('Gửi Ưu đãi/Tin nhắn', style: TextStyle(color: AppColors.textLight)),
                onPressed: () {
                  Navigator.pushNamed(context, '/provider_management');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPotentialCustomerItem(String name, String profile, String match) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$name ($profile)',
              style: const TextStyle(color: AppColors.textLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            match,
            style: const TextStyle(color: AppColors.accentLight, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- Quản lý dịch vụ ---
  Widget _buildManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quản lý Dịch vụ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                context,
                'Thêm Dịch vụ mới',
                Icons.add_business,
                () => Navigator.pushNamed(context, '/manage_services'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildManagementButton(
                context,
                'Danh sách Dịch vụ',
                Icons.list_alt,
                () => Navigator.pushNamed(context, '/manage_services'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.textLight),
      label: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textLight)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // --- Lịch đặt chỗ ---
  Widget _buildBookingCalendar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lịch Đặt chỗ sắp tới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBookingItem('Nguyễn Văn A', 'Phòng Deluxe (2 đêm)', '20/11'),
                const Divider(),
                _buildBookingItem('Trần Thị B', 'Tour Trải nghiệm (1 ngày)', '25/11'),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/provider_management'),
                    child: const Text('Xem chi tiết lịch >'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingItem(String customer, String service, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: AppColors.secondaryOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(service, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
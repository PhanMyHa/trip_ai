import 'package:fe/models/data.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';

// Mock danh sách dịch vụ đã đăng
final mockProviderServices = [
  Place(
    id: 'S001',
    name: 'Khách sạn Đồi Thông',
    location: 'Đà Lạt',
    category: 'Khách sạn',
    rating: 4.8,
    priceFrom: 1800000,
  ),
  Place(
    id: 'S002',
    name: 'Tour Cắm trại Hồ Tuyền Lâm',
    location: 'Đà Lạt',
    category: 'Tour',
    rating: 4.5,
    priceFrom: 850000,
  ),
];

class ManageServiceScreen extends StatelessWidget {
  const ManageServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản Lý Dịch Vụ'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textLight,
          bottom: const TabBar(
            indicatorColor: AppColors.secondaryOrange,
            labelColor: AppColors.textLight,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.list_alt_rounded), text: 'Dịch vụ đã đăng'),
              Tab(
                icon: Icon(Icons.add_business_rounded),
                text: 'Đăng dịch vụ mới',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildServiceList(context), _buildServiceForm(context)],
        ),
      ),
    );
  }

  // --- Tab: Danh sách Dịch vụ ---
  Widget _buildServiceList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mockProviderServices.length,
      itemBuilder: (context, index) {
        final service = mockProviderServices[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Icon(
                service.category == 'Khách sạn'
                    ? Icons.hotel_rounded
                    : Icons.tour_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            title: Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${service.location} - ${service.category}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // Giả lập mở form sửa
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sửa dịch vụ: ${service.name}')),
                  );
                } else if (value == 'delete') {
                  // Giả lập xóa
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa dịch vụ: ${service.name}')),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Tab: Form Đăng dịch vụ mới ---
  Widget _buildServiceForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đăng ký dịch vụ mới',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tên Dịch vụ (VD: Khách sạn A, Tour B)',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập tên dịch vụ.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Địa điểm',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá khởi điểm (VNĐ)',
                prefixIcon: Icon(Icons.paid_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mô tả chi tiết',
                prefixIcon: Icon(Icons.description_rounded),
              ),
            ),
            const SizedBox(height: 20),
            _buildImageUploadSection(context),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.textLight,
                ),
                label: const Text('Đăng Dịch Vụ'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dịch vụ đang được xét duyệt.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: 'Khách sạn',
      decoration: const InputDecoration(
        labelText: 'Loại hình Dịch vụ',
        prefixIcon: Icon(Icons.category_rounded),
      ),
      items: [
        'Khách sạn',
        'Tour',
        'Vé máy bay',
        'Địa điểm tham quan',
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
    );
  }

  // --- Sửa _buildImageUploadSection() ---
  Widget _buildImageUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh & Video',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mở thư viện ảnh để tải lên.')),
            );
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'Tải lên ảnh/video (Tối đa 5)',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

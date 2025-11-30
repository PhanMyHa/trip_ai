import 'package:fe/models/data.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile user = mockCurrentUser;

  void _editProfile(BuildContext context) {
    // Mock Navigate to Edit Form
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: user),
      ),
    ).then((updatedUser) {
      if (updatedUser != null && updatedUser is UserProfile) {
        setState(() {
          user = updatedUser;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar và Thông tin cơ bản
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(user.avatarUrl),
                    backgroundColor: AppColors.accentLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Tiểu sử/Mô tả
            _buildSectionTitle('Giới thiệu'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(user.bio),
              ),
            ),
            const SizedBox(height: 20),

            // Sở thích
            _buildSectionTitle('Sở thích du lịch'),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: user.interests
                  .map((interest) => Chip(
                        label: Text(interest),
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Ngân sách
            _buildSectionTitle('Ngân sách (Kế hoạch AI)'),
            _buildInfoRow(
                Icons.account_balance_wallet_rounded, 'Mức Ngân Sách', user.budgetRange),
            const SizedBox(height: 20),

            // Lịch sử Du lịch
            _buildSectionTitle('Lịch sử Du lịch (Mock)'),
            _buildHistoryItem('Đà Lạt', '05/2024', Icons.bungalow_rounded),
            _buildHistoryItem('Phú Quốc', '01/2024', Icons.beach_access_rounded),
            _buildHistoryItem('Hà Nội', '10/2023', Icons.location_city_rounded),
            const SizedBox(height: 30),

            // Nút Đăng xuất
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.errorRed),
                label: const Text('Đăng Xuất'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đăng xuất!')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(label),
      trailing: Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryOrange)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildHistoryItem(String title, String date, IconData icon) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondaryOrange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Đã đi vào $date'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

// --- Form Chỉnh sửa Hồ sơ ---
class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late String _budget;

  final List<String> availableInterests = [
    'Biển',
    'Núi',
    'Thành phố',
    'Nghỉ dưỡng',
    'Ẩm thực',
    'Cắm trại',
    'Chụp ảnh'
  ];
  late List<String> _selectedInterests;

  final List<String> budgetOptions = ['Thấp', 'Trung bình', 'Cao'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio);
    _budget = widget.user.budgetRange;
    _selectedInterests = List.from(widget.user.interests);
  }

  void _saveProfile() {
    final updatedUser = UserProfile(
      id: widget.user.id,
      name: _nameController.text,
      email: widget.user.email,
      avatarUrl: widget.user.avatarUrl,
      bio: _bioController.text,
      interests: _selectedInterests,
      budgetRange: _budget,
    );
    Navigator.pop(context, updatedUser); // Trả về UserProfile mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Hồ Sơ'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Lưu',
                style: TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên và Bio
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và Tên',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tiểu sử / Giới thiệu bản thân',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_rounded),
              ),
            ),
            const SizedBox(height: 24),

            // Ngân sách du lịch
            const Text('Ngân sách Du lịch (Dùng cho AI)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _budget,
              decoration: const InputDecoration(
                labelText: 'Chọn Mức Ngân Sách',
                prefixIcon: Icon(Icons.paid_rounded),
              ),
              items: budgetOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _budget = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Sở thích du lịch
            const Text('Chọn Sở thích Du lịch',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return ActionChip(
                  label: Text(interest),
                  avatar: isSelected
                      ? const Icon(Icons.check, color: AppColors.textLight)
                      : null,
                  backgroundColor: isSelected
                      ? AppColors.secondaryOrange
                      : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textLight : AppColors.textDark,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
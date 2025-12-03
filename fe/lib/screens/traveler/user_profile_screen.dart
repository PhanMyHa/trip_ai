// lib/screens/profile/profile_screen.dart
import 'package:fe/theme/app_theme.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String?
  userId; // null = xem profile của mình, có giá trị = xem người khác
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  List<dynamic> _bookingHistory = [];
  List<dynamic> _userReels = []; // Thêm để hiển thị reel của người đó sau này
  bool _isLoading = true;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = widget.userId == null;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? profile;
      List<dynamic> bookings = [];

      if (_isCurrentUser) {
        // Xem profile của mình
        print('📱 Loading current user profile...');
        profile = await ApiService.getUserProfile();
        print('✅ Profile loaded: ${profile != null ? "Success" : "Null"}');
        if (profile != null) {
          print('   Name: ${profile['name']}');
          print('   Email: ${profile['email']}');
        }

        print('📚 Loading bookings...');
        bookings = await ApiService.getUserBookings();
        print('✅ Bookings loaded: ${bookings.length} items');
      } else {
        // Xem profile người khác theo ID
        print('👤 Loading user by ID: ${widget.userId}');
        profile = await ApiService.getUserById(widget.userId!);
        print('✅ Profile loaded: ${profile != null ? "Success" : "Null"}');
        bookings = [];
      }

      if (profile == null) {
        print('❌ Profile is null after API call');
      }

      setState(() {
        _userData = profile;
        _bookingHistory = _isCurrentUser ? bookings : [];
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Error loading user data: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải thông tin: $e')));
      }
    }
  }

  void _editProfile(BuildContext context) {
    if (_userData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData!),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
      }
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ApiService.logout();
      await AuthService().logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không thể tải thông tin'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final name = _userData!['name'] ?? 'Người dùng';
    final email = _userData!['email'] ?? '';
    final avatarUrl = _userData!['avatarUrl'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name, style: const TextStyle(color: Colors.black87)),
        actions: _isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  onPressed: () => _editProfile(context),
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.accentLight,
                child: ClipOval(
                  child: Image.network(
                    avatarUrl ??
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=FF6B6B&color=fff&size=256',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&color=fff&size=256',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              if (_userData!['bio'] != null &&
                  _userData!['bio'].toString().isNotEmpty) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _userData!['bio'],
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_userData!['interests'] != null &&
                  (_userData!['interests'] as List).isNotEmpty) ...[
                const Text(
                  'Sở thích du lịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (_userData!['interests'] as List)
                      .map(
                        (i) => Chip(
                          label: Text(i.toString()),
                          backgroundColor: AppColors.primaryBlue.withOpacity(
                            0.1,
                          ),
                          labelStyle: const TextStyle(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Chỉ hiện lịch sử đặt chỗ nếu là chính mình
              if (_isCurrentUser) ...[
                const Text(
                  'Lịch sử Du lịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_bookingHistory.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Chưa có lịch sử đặt chỗ'),
                    ),
                  )
                else
                  ..._bookingHistory
                      .take(5)
                      .map(
                        (b) => _buildHistoryItem(
                          b['serviceId']?['title'] ?? 'Dịch vụ',
                          _formatDate(b['createdAt']),
                          _getCategoryIcon(b['serviceId']?['category']),
                        ),
                      ),
                const SizedBox(height: 20),
              ],

              // Chỉ hiện nút đăng xuất nếu là mình
              if (_isCurrentUser)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text(
                      'Đăng Xuất',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'N/A';
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Hotel':
        return Icons.hotel_rounded;
      case 'Tour':
        return Icons.tour_rounded;
      case 'Restaurant':
        return Icons.restaurant_rounded;
      case 'Flight':
        return Icons.flight_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Widget _buildHistoryItem(String title, String date, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondaryOrange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Đặt vào $date'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

// EditProfileScreen giữ nguyên như cũ của bạn
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late String _budget;
  bool _isSaving = false;

  final List<String> availableInterests = [
    'Biển',
    'Núi',
    'Thành phố',
    'Nghỉ dưỡng',
    'Ẩm thực',
    'Cắm trại',
    'Chụp ảnh',
  ];
  late List<String> _selectedInterests;

  final List<String> budgetOptions = ['Thấp', 'Trung bình', 'Cao'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['name'] ?? '',
    );
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _phoneController = TextEditingController(
      text: widget.userData['contactPhone'] ?? '',
    );
    _budget = widget.userData['budgetRange'] ?? 'Trung bình';
    _selectedInterests = widget.userData['interests'] != null
        ? List<String>.from(widget.userData['interests'])
        : [];
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await ApiService.updateUserProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        interests: _selectedInterests,
        budgetRange: _budget,
        contactPhone: _phoneController.text.trim(),
      );

      if (result != null && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.')),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Hồ Sơ'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 24),

            // Ngân sách du lịch
            const Text(
              'Ngân sách Du lịch (Dùng cho AI)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
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
            const Text(
              'Chọn Sở thích Du lịch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
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
                    color: isSelected
                        ? AppColors.textLight
                        : AppColors.textDark,
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

// ... (giữ nguyên toàn bộ EditProfileScreen bạn đã viết)

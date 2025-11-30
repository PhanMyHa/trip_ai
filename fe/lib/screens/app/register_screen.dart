import 'package:fe/models/data.dart';
import 'package:fe/screens/app/login_screen.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.traveller;
  String _email = '';
  String _password = '';
  String _name = '';

  void _register(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final result = await ApiService.register(
      name: _name,
      email: _email,
      password: _password,
      role: _selectedRole.toString().split('.').last, // "traveller" hoặc "provider"
    );

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công! Đang chuyển về đăng nhập...')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Đăng ký thất bại')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
// ... (giữ nguyên code widget)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký Tài Khoản'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chọn Vai trò của bạn',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 15),

                // Chọn Vai trò (Role Selector)
                _buildRoleSelector(),
                const SizedBox(height: 30),

                // Tên
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Họ và Tên',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên.' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập Email.' : null,
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 16),

                // Mật khẩu
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_rounded),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự.' : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 30),

                // Nút Đăng ký
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _register(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryOrange),
                    child: const Text('Đăng Ký Tài Khoản'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoleChip(UserRole.traveller, Icons.person_rounded, 'Du khách'),
        const SizedBox(width: 15),
        _buildRoleChip(
            UserRole.provider, Icons.business_center_rounded, 'Nhà cung cấp'),
      ],
    );
  }

  Widget _buildRoleChip(UserRole role, IconData icon, String label) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
              width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.textLight : AppColors.textDark,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
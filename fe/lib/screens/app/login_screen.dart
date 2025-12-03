
import 'package:fe/models/user.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.traveller;
  String _email = '';
  String _password = '';

  void _login(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final result = await ApiService.login(email: _email, password: _password);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công! Chào ${result['user']['name']}')),
      );

      // Chuyển hướng theo role
      final role = result['user']['role'];
      if (role == 'provider') {
        Navigator.of(context).pushNamedAndRemoveUntil('/provider_dashboard', (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Đăng nhập thất bại')),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.airplanemode_active_rounded,
                    size: 80, color: AppColors.primaryBlue),
                const SizedBox(height: 10),
                const Text(
                  'Chào mừng đến với Travel AI',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 30),

                // Chọn Vai trò (Role Selector)
                _buildRoleSelector(),
                const SizedBox(height: 20),

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

                // Nút Đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _login(context),
                    child: const Text('Đăng Nhập'),
                  ),
                ),
                const SizedBox(height: 20),

                // Chuyển sang Đăng ký
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Bạn chưa có tài khoản? Đăng ký ngay'),
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
          color: isSelected ? AppColors.secondaryOrange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected ? AppColors.secondaryOrange : Colors.grey.shade300,
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
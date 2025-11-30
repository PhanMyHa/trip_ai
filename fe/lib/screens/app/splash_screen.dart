import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  // Giả lập thời gian load dữ liệu ban đầu
  void _startApp() async {
    await Future.delayed(const Duration(seconds: 3));
    // Sau khi load, chuyển sang màn hình đăng nhập
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.travel_explore_rounded,
                  size: 100, color: AppColors.secondaryOrange),
              const SizedBox(height: 20),
              const Text(
                'Travel AI',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textLight,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Lập Kế Hoạch Thông Minh',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textLight.withOpacity(0.8),
                  
                  
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryOrange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
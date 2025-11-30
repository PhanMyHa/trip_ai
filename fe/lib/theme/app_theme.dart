import 'package:flutter/material.dart';

// Màu sắc chủ đạo: Xanh biển (Primary) và Cam/Vàng (Secondary/Accent)
class AppColors {
  static const Color primaryBlue = Color(0xFF0077B6); // Xanh biển sâu
  static const Color secondaryOrange = Color(0xFFF7B733); // Cam tươi sáng
  static const Color accentLight = Color(0xFFA0E7E5); // Xanh nhạt
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF3C3C3C);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFEE6352);
  static const Color successGreen = Color(0xFF57CC99);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter', // Sử dụng font mặc định nếu không có font tùy chỉnh
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryOrange,
      background: AppColors.backgroundLight,
      surface: AppColors.backgroundLight,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textDark,
      onBackground: AppColors.textDark,
      onSurface: AppColors.textDark,
      error: AppColors.errorRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0), // Bo góc 24px
      ),
      surfaceTintColor: AppColors.backgroundLight,
    ),
    // Thiết lập cho các widget tương tác
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textLight,
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    // Thêm Input Decoration Theme cho Forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: const TextStyle(color: AppColors.primaryBlue),
      floatingLabelStyle: const TextStyle(
        color: AppColors.secondaryOrange,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(
          color: AppColors.secondaryOrange,
          width: 2,
        ),
      ),
    ),
    // Theme cho Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.backgroundLight,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

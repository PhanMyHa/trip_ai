// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  User({required this.id, required this.name, required this.email, required this.role, this.avatarUrl});
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null;
  bool get isProvider => _currentUser?.role == 'provider';
  bool get isTraveller => _currentUser?.role == 'traveller';

  // Load user từ SharedPreferences khi mở app
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final userJson = {
      'id': prefs.getString('userId'),
      'name': prefs.getString('userName'),
      'email': prefs.getString('userEmail'),
      'role': prefs.getString('userRole'),
      'avatarUrl': prefs.getString('userAvatar'),
    };

    if (userJson.values.every((e) => e != null)) {
      _currentUser = User(
        id: userJson['id']!,
        name: userJson['name']!,
        email: userJson['email']!,
        role: userJson['role']!,
        avatarUrl: userJson['avatarUrl'],
      );
      _token = token;
      notifyListeners();
    }
  }

  // Lưu user sau khi login/register thành công
  Future<void> loginUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final user = data['user'];

    await prefs.setString('token', data['token']);
    await prefs.setString('userId', user['id']);
    await prefs.setString('userName', user['name']);
    await prefs.setString('userEmail', user['email']);
    await prefs.setString('userRole', user['role']);
    if (user['avatarUrl'] != null) await prefs.setString('userAvatar', user['avatarUrl']);

    _currentUser = User(
      id: user['id'],
      name: user['name'],
      email: user['email'],
      role: user['role'],
      avatarUrl: user['avatarUrl'],
    );
    _token = data['token'];
    notifyListeners();
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}
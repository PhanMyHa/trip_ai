import 'package:fe/screens/app/home_screen.dart';
import 'package:fe/screens/app/login_screen.dart';
import 'package:fe/screens/provider/provider_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authService = Provider.of<AuthService>(navigatorKey.currentContext!, listen: false);

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => authService.isLoggedIn
              ? (authService.isProvider ? ProviderDashboard() : HomeScreen())
              : LoginScreen(),
        );

      case '/provider_dashboard':
        if (!authService.isLoggedIn || !authService.isProvider) {
          return MaterialPageRoute(builder: (_) => LoginScreen()); // chặn ngay
        }
        return MaterialPageRoute(builder: (_) => ProviderDashboard());

      // các route khác...
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
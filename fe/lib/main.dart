import 'package:fe/models/data.dart';
import 'package:fe/screens/app/advanced_search_screen.dart';
import 'package:fe/screens/app/ai_request_srceen.dart';
import 'package:fe/screens/app/ai_result_screen.dart';
import 'package:fe/screens/app/booking_confirm_screen.dart';
import 'package:fe/screens/app/booking_screen.dart';
import 'package:fe/screens/app/checkout_screen.dart';
import 'package:fe/screens/app/home_screen.dart';
import 'package:fe/screens/app/login_screen.dart';
import 'package:fe/screens/app/my_booking_screen.dart';
import 'package:fe/screens/app/new_feed_screen.dart';
import 'package:fe/screens/app/place_detail.dart';
import 'package:fe/screens/app/register_screen.dart';
import 'package:fe/screens/app/splash_screen.dart';
import 'package:fe/screens/app/voucher_screen.dart';
import 'package:fe/screens/chat/chat_screen.dart';
import 'package:fe/screens/provider/manage_service_screen.dart';
import 'package:fe/screens/provider/provider_manager_screen.dart';
import 'package:fe/screens/provider/provider_screen.dart';
import 'package:fe/screens/traveler/user_profile_screen.dart';
import 'package:fe/services/auth_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.loadUserFromStorage();
  runApp(const TravelAIApp());
}

class TravelAIApp extends StatelessWidget {
  const TravelAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final Map<String, Widget Function(BuildContext)> appRoutes = {
      // --- AUTH & CORE FLOW ---
      '/splash': (context) => const SplashScreen(), 
      '/login': (context) => const LoginScreen(), 
      '/register': (context) => const RegisterScreen(), 
      
      // --- TRAVELER CORE ---
      '/': (context) => const MainScreen(),
      '/search': (context) => const SearchScreen(),
      '/ai_request': (context) => const AIRequestScreen(),
      '/ai_result': (context) => const AIResultScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/newsfeed': (context) => const NewsfeedScreen(),
      '/chat_list': (context) => const ChatListScreen(),
      '/voucher': (context) => const VoucherScreen(),
      '/notifications': (context) => const NotificationScreen(),
      
      // --- BOOKING & PAYMENT ---
      '/booking': (context) => const BookingScreen(), 
      // Checkout và Confirmation sẽ dùng onGenerateRoute vì cần arguments
      '/my_bookings': (context) => const MyBookingsScreen(), // Mới
      
      // --- PROVIDER CORE ---
      '/provider_dashboard': (context) => const ProviderDashboard(),
      '/manage_services': (context) => const ManageServiceScreen(), 
      '/provider_management': (context) => const ProviderManagementScreen(), // Mới (Quản lý Bookings, Leads, Analytics)
    };

    return MaterialApp(
      title: 'Travel AI App',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Bắt đầu từ Splash Screen
      routes: appRoutes,
      onGenerateRoute: (settings) {
        if (settings.name == '/place_detail') {
          final args = settings.arguments as Place;
          return MaterialPageRoute(
            builder: (context) {
              return PlaceDetailScreen(place: args);
            },
          );
        }
        
        // --- Xử lý BookingScreen với arguments ---
        if (settings.name == '/booking') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
                builder: (context) => BookingScreen(
                    initialTab: args?['initialTab'] ?? 'Hotel',
                    placeName: args?['placeName'],
                ),
            );
        }
        
        // --- Xử lý CheckoutScreen với arguments ---
        if (settings.name == '/checkout') {
            final args = settings.arguments as BookingSummary?;
            // Dùng mockSummary nếu không có args (đảm bảo không lỗi)
            return MaterialPageRoute(
                builder: (context) => CheckoutScreen(
                    summary: args ?? mockSummary, 
                ),
            );
        }
        
        // --- Xử lý BookingConfirmationScreen với arguments ---
        if (settings.name == '/booking_confirmation') {
            final args = settings.arguments as BookingSummary;
            return MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(
                    summary: args,
                ),
            );
        }
        
        return null;
      },
    );
  }
}

// --- Màn hình Chính với Bottom Navigation Bar ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const SearchScreen(), // Dùng lại Search Screen cho tab này
    const NewsfeedScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded),
              label: 'Reels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Tôi',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          // Sử dụng type.fixed để các icon không bị dịch chuyển
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.backgroundLight,
        ),
      ),
    );
  }
}

// Màn hình Thông báo (Mock)
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final List<Map<String, dynamic>> mockNotifications = const [
    {
      'title': 'AI: Lịch trình Đà Lạt đã sẵn sàng!',
      'subtitle': 'Lịch trình 3 ngày đã được cá nhân hóa theo sở thích của bạn. Xem ngay.',
      'icon': Icons.psychology_rounded,
      'color': AppColors.secondaryOrange,
      'read': false,
    },
    {
      'title': 'Khuyến mãi: Giảm 20% khách sạn',
      'subtitle': 'Ưu đãi chỉ còn 24 giờ. Đừng bỏ lỡ cơ hội đặt phòng giá tốt!',
      'icon': Icons.local_offer_rounded,
      'color': AppColors.primaryBlue,
      'read': false,
    },
    {
      'title': 'Đặt chỗ thành công',
      'subtitle': 'Booking khách sạn Đồi Thông đã được xác nhận. Mã: #928374',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.successGreen,
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Import NotificationCard từ common_widgets.dart
    final NotificationCard = (
        {required String title, required String subtitle, required IconData icon, required Color iconColor, required bool isRead}) =>
        // Giả lập NotificationCard vì nó không thể được import trong ngữ cảnh này
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(title, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
            subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: isRead ? null : const Icon(Icons.circle, color: AppColors.secondaryOrange, size: 8),
            onTap: () {},
          ),
        );


    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notification = mockNotifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: NotificationCard(
              title: notification['title'] as String,
              subtitle: notification['subtitle'] as String,
              icon: notification['icon'] as IconData,
              iconColor: notification['color'] as Color,
              isRead: notification['read'] as bool,
            ),
          );
        },
      ),
    );
  }
}
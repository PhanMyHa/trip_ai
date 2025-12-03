import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../models/service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.18:5000/api';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        print('Register failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error during registration: $e');
      return {
        'success': false,
        'message': 'Connection error. Please check if the server is running.',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await AuthService().loginUser(data);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('userRole', data['user']['role']);
          await prefs.setString('userName', data['user']['name']);
        }
        return data;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Connection error. Please check if the server is running.',
      };
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Fetch danh sách dịch vụ (places)
  static Future<List<Service>> getServices({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      final token = await getToken();

      // Build query parameters
      Map<String, String> queryParams = {};
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();

      final uri = Uri.parse(
        '$baseUrl/services',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  // Fetch chi tiết một dịch vụ
  static Future<Service?> getServiceById(String serviceId) async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Service.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load service');
      }
    } catch (e) {
      print('Error fetching service: $e');
      return null;
    }
  }

  // Fetch user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      print('🔑 Token: ${token != null ? "Present" : "Missing"}');
      if (token == null) {
        print('❌ No token found, returning null');
        return null;
      }

      final url = '$baseUrl/users/profile';
      print('🌐 Calling: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print(
        '📄 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Parsed profile data successfully');
        return data;
      }
      print('⚠️ Non-200 status, returning null');
      return null;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  // Get user by ID (public profile)
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>?> updateUserProfile({
    String? name,
    String? bio,
    List<String>? interests,
    String? budgetRange,
    String? contactPhone,
    String? avatarUrl,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (interests != null) body['interests'] = interests;
      if (budgetRange != null) body['budgetRange'] = budgetRange;
      if (contactPhone != null) body['contactPhone'] = contactPhone;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Get user bookings
  static Future<List<dynamic>> getUserBookings() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/users/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Get service reviews
  static Future<Map<String, dynamic>> getServiceReviews(
    String serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/services/$serviceId/reviews?page=$page&limit=$limit',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'reviews': [], 'total': 0};
    } catch (e) {
      print('Error fetching reviews: $e');
      return {'reviews': [], 'total': 0};
    }
  }

  // Create a review
  static Future<bool> createReview({
    required String serviceId,
    required double rating,
    required String comment,
    List<String>? photos,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/services/$serviceId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': rating,
          'comment': comment,
          'photos': photos ?? [],
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating review: $e');
      return false;
    }
  }

  // Toggle favorite
  static Future<bool> toggleFavorite(String serviceId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/services/$serviceId/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Check if service is favorited
  static Future<bool> isFavorite(String serviceId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/users/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> favorites = json.decode(response.body);
        return favorites.any((fav) => fav['_id'] == serviceId);
      }
      return false;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // Get vouchers
  static Future<List<dynamic>> getVouchers({String? category}) async {
    try {
      Map<String, String> queryParams = {};
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse(
        '$baseUrl/vouchers',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching vouchers: $e');
      return [];
    }
  }

  // Apply voucher
  static Future<Map<String, dynamic>?> applyVoucher(
    String code,
    double orderValue, {
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vouchers/apply'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': code,
          'orderValue': orderValue,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error applying voucher: $e');
      return null;
    }
  }

  // Get user itineraries
  static Future<List<dynamic>> getUserItineraries({String? status}) async {
    try {
      final token = await getToken();
      if (token == null) return [];

      Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/itineraries',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching itineraries: $e');
      return [];
    }
  }

  // Get itinerary by ID
  static Future<Map<String, dynamic>?> getItineraryById(String id) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/itineraries/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching itinerary: $e');
      return null;
    }
  }

  // Create itinerary
  static Future<bool> createItinerary(
    Map<String, dynamic> itineraryData,
  ) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/itineraries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(itineraryData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating itinerary: $e');
      return false;
    }
  }

  // Toggle save itinerary
  static Future<bool> toggleSaveItinerary(String id) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/itineraries/$id/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling save itinerary: $e');
      return false;
    }
  }

  // Create booking
  static Future<Map<String, dynamic>?> createBooking({
    required String serviceId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    String? specialRequests,
    String? voucherCode,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'serviceId': serviceId,
          'checkInDate': checkInDate.toIso8601String(),
          'checkOutDate': checkOutDate.toIso8601String(),
          'numberOfGuests': numberOfGuests,
          if (specialRequests != null) 'specialRequests': specialRequests,
          if (voucherCode != null) 'voucherCode': voucherCode,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Get bookings
  static Future<List<dynamic>> getBookings({String? status}) async {
    try {
      final token = await getToken();
      if (token == null) return [];

      Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/bookings',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Get booking by ID
  static Future<Map<String, dynamic>?> getBookingById(String id) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  // Cancel booking
  static Future<bool> cancelBooking(String id) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$id/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Confirm payment
  static Future<bool> confirmPayment(String id) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$id/confirm-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error confirming payment: $e');
      return false;
    }
  }

  // Get booking stats (for providers)
  static Future<Map<String, dynamic>?> getBookingStats() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching booking stats: $e');
      return null;
    }
  }

  // ==================== REEL METHODS ====================

  // Get reels feed
  // ==================== REEL METHODS ====================

  // Get reels feed - ĐÃ SỬA HOÀN TOÀN
  static Future<List<dynamic>> getReels({int? limit, int? skip}) async {
    try {
      Map<String, String> queryParams = {};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (skip != null) queryParams['skip'] = skip.toString();

      final uri = Uri.parse(
        '$baseUrl/reels',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(
          'Raw reels API response: $jsonResponse',
        ); // Debug log (có thể xóa sau)

        // Backend trả: { success: true, message: "...", data: [...] }
        return jsonResponse['data'] ?? [];
      } else {
        print('Reels API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching reels: $e');
      return [];
    }
  }

  // Get reel by ID
  static Future<Map<String, dynamic>?> getReelById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reels/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching reel: $e');
      return null;
    }
  }

  // Toggle like reel
  static Future<bool> toggleLikeReel(String id) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/reels/$id/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // Increment view
  static Future<bool> incrementReelView(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reels/$id/view'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error incrementing view: $e');
      return false;
    }
  }

  // Increment share
  static Future<bool> incrementReelShare(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reels/$id/share'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error incrementing share: $e');
      return false;
    }
  }

  // Create reel
  static Future<Map<String, dynamic>?> createReel({
    required String serviceId,
    required String videoUrl,
    required String caption,
    List<String>? hashtags,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/reels'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'serviceId': serviceId,
          'videoUrl': videoUrl,
          'caption': caption,
          if (hashtags != null) 'hashtags': hashtags,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error creating reel: $e');
      return null;
    }
  }

  // AI Recommendations
  static Future<Map<String, dynamic>?> generateAIItinerary({
    required String destination,
    required String startDate,
    required String endDate,
    required int travelers,
    required String budget,
    List<String>? interests,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found for AI request');
        return null;
      }

      print('🤖 Calling AI API: $destination, $startDate to $endDate');

      final response = await http.post(
        Uri.parse('$baseUrl/ai/recommend-itinerary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'destination': destination,
          'startDate': startDate,
          'endDate': endDate,
          'travelers': travelers,
          'budget': budget,
          if (interests != null && interests.isNotEmpty) 'interests': interests,
        }),
      );

      print('AI API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ AI Itinerary generated successfully');
        return data['data'];
      } else {
        print('AI API Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating AI itinerary: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAIModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ai/model-info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting AI model info: $e');
      return null;
    }
  }
}

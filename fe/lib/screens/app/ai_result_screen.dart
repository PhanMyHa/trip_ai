import 'dart:convert';
import 'package:fe/models/service.dart';
import 'package:fe/services/api_service.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Model classes for AI data
class AIRecommendation {
  final String queryId;
  final String destination;
  final String travelerProfile;
  final List<DailySchedule> schedule;

  AIRecommendation({
    required this.queryId,
    required this.destination,
    required this.travelerProfile,
    required this.schedule,
  });
}

class DailySchedule {
  final int day;
  final String date;
  final String theme;
  final String weatherForecast;
  final String aiTip;
  final List<Activity> activities;

  DailySchedule({
    required this.day,
    required this.date,
    required this.theme,
    required this.weatherForecast,
    required this.aiTip,
    required this.activities,
  });
}

class Activity {
  final String time;
  final String title;
  final String placeId;
  final String notes;

  Activity({
    required this.time,
    required this.title,
    required this.placeId,
    required this.notes,
  });
}

// Service giả lập để load AI JSON
class AIService {
  Future<AIRecommendation> fetchMockAIRecommendation() async {
    // Đọc mock JSON file
    final String response = await rootBundle.loadString('mock_api_data.json');
    final data = await json.decode(response);
    final jsonResult = data['ai_recommendation'];

    // Chuyển đổi JSON sang Dart object
    List<DailySchedule> schedules = (jsonResult['schedule'] as List)
        .map(
          (s) => DailySchedule(
            day: s['day'],
            date: s['date'],
            theme: s['theme'],
            weatherForecast: s['weather_forecast'],
            aiTip: s['ai_tip'],
            activities: (s['activities'] as List)
                .map(
                  (a) => Activity(
                    time: a['time'],
                    title: a['title'],
                    placeId: a['place_id'],
                    notes: a['notes'],
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return AIRecommendation(
      queryId: jsonResult['query_id'],
      destination: jsonResult['destination'],
      travelerProfile: jsonResult['traveler_profile'],
      schedule: schedules,
    );
  }
}

class AIResultScreen extends StatefulWidget {
  const AIResultScreen({super.key});

  @override
  State<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends State<AIResultScreen> {
  AIRecommendation? _aiResult;
  int _selectedDayIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAIResult();
  }

  void _loadAIResult() {
    // Get data from route arguments (real AI data) or load mock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null && args is Map<String, dynamic>) {
        // Real AI data from API
        print('📊 Loading real AI data from API');
        _loadRealAIData(args);
      } else {
        // Fallback to mock data
        print('📋 Loading mock AI data');
        _loadMockData();
      }
    });
  }

  void _loadRealAIData(Map<String, dynamic> data) {
    try {
      List<DailySchedule> schedules = (data['dailySchedule'] as List)
          .map(
            (s) => DailySchedule(
              day: s['day'],
              date: s['date'] ?? 'Day ${s['day']}',
              theme: s['theme'] ?? 'Travel Day',
              weatherForecast: s['weather_forecast'] ?? 'Sunny, 25-30°C',
              aiTip: s['ai_tip'] ?? 'Enjoy your trip!',
              activities: (s['activities'] as List)
                  .map(
                    (a) => Activity(
                      time: a['time'],
                      title: a['title'],
                      placeId: a['place_id'],
                      notes: a['notes'] ?? '',
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      setState(() {
        _aiResult = AIRecommendation(
          queryId: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          destination: data['destination'] ?? 'Unknown',
          travelerProfile: '${data['travelers']} người - ${data['budget']}',
          schedule: schedules,
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading real AI data: $e');
      _loadMockData();
    }
  }

  Future<void> _loadMockData() async {
    try {
      final mockResult = await AIService().fetchMockAIRecommendation();
      setState(() {
        _aiResult = mockResult;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading mock data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Trình AI Đề Xuất'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _aiResult == null || _aiResult!.schedule.isEmpty
          ? const Center(child: Text('Không tìm thấy lịch trình.'))
          : _buildContent(),
      floatingActionButton: !_isLoading && _aiResult != null
          ? AIActionButton(
              text: 'Regenerate with AI',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/ai_request');
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    final result = _aiResult!;
    final currentDay = result.schedule[_selectedDayIndex];

    return Column(
      children: [
        _buildHeader(result),
        _buildDaySelector(result.schedule),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildWeatherAndTheme(currentDay),
              const SizedBox(height: 20),
              _buildAITipCard(currentDay),
              const SizedBox(height: 20),
              ...currentDay.activities.map(
                (activity) => _buildActivityTimeline(context, activity),
              ),
              const SizedBox(height: 80), // Padding cho FAB
            ],
          ),
        ),
      ],
    );
  }

  // --- Header thông tin chung ---
  Widget _buildHeader(AIRecommendation result) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.destination,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hồ sơ: ${result.travelerProfile}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- Bộ chọn ngày ---
  Widget _buildDaySelector(List<DailySchedule> schedules) {
    return Container(
      height: 60,
      color: Colors.grey.shade100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              index == 0 ? 16 : 8,
              8,
              index == schedules.length - 1 ? 16 : 8,
              8,
            ),
            child: ChoiceChip(
              label: Text('Ngày ${schedules[index].day}'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                }
              },
              selectedColor: AppColors.secondaryOrange,
              backgroundColor: AppColors.backgroundLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.textLight : AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Thông tin thời tiết và Chủ đề ngày ---
  Widget _buildWeatherAndTheme(DailySchedule day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientCard(
          padding: const EdgeInsets.all(12),
          radius: 16,
          gradientColors: const [AppColors.accentLight, AppColors.primaryBlue],
          child: Row(
            children: [
              const Icon(
                Icons.cloud_queue_rounded,
                color: AppColors.textLight,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thời tiết: ${day.weatherForecast}',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Chủ đề: ${day.theme}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Thẻ mẹo AI ---
  Widget _buildAITipCard(DailySchedule day) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.secondaryOrange),
                SizedBox(width: 8),
                Text(
                  'Mẹo AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.secondaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(day.aiTip, style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  // --- Timeline Hoạt động ---
  Widget _buildActivityTimeline(BuildContext context, Activity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Text(
                activity.time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Container(
                width: 2,
                height: 50, // Chiều cao của đường kẻ
                color: AppColors.primaryBlue.withOpacity(0.5),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Activity Card
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.notes,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Xem Địa điểm'),
                        onPressed: () async {
                          // Fetch service by ID or use first available
                          final services = await ApiService.getServices();
                          if (services.isNotEmpty) {
                            // Try to find by ID or use first service
                            final service = services.firstWhere(
                              (s) =>
                                  s.id == activity.placeId ||
                                  s.serviceId == activity.placeId,
                              orElse: () => services.first,
                            );
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                '/place_detail',
                                arguments: service,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

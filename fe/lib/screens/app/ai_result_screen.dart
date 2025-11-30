import 'dart:convert';
import 'package:fe/models/data.dart';
import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// Service giả lập để load AI JSON
class AIService {
  Future<AIRecommendation> fetchMockAIRecommendation() async {
    // Đọc mock JSON file
    final String response = await rootBundle.loadString('mock_api_data.json');
    final data = await json.decode(response);
    final jsonResult = data['ai_recommendation'];

    // Chuyển đổi JSON sang Dart object
    List<DailySchedule> schedules = (jsonResult['schedule'] as List)
        .map((s) => DailySchedule(
              day: s['day'],
              date: s['date'],
              theme: s['theme'],
              weatherForecast: s['weather_forecast'],
              aiTip: s['ai_tip'],
              activities: (s['activities'] as List)
                  .map((a) => Activity(
                        time: a['time'],
                        title: a['title'],
                        placeId: a['place_id'],
                        notes: a['notes'],
                      ))
                  .toList(),
            ))
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
  late Future<AIRecommendation> _aiResultFuture;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _aiResultFuture = AIService().fetchMockAIRecommendation();
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
      body: FutureBuilder<AIRecommendation>(
        future: _aiResultFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.schedule.isEmpty) {
            return const Center(child: Text('Không tìm thấy lịch trình.'));
          }

          final result = snapshot.data!;
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
                    ...currentDay.activities.map((activity) =>
                        _buildActivityTimeline(context, activity)),
                    const SizedBox(height: 80), // Padding cho FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AIActionButton(
        text: 'Regenerate with AI',
        onPressed: () {
          // Xử lý tạo lại lịch trình
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang tạo lại lịch trình...')),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                color: AppColors.primaryBlue),
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
                index == 0 ? 16 : 8, 8, index == schedules.length - 1 ? 16 : 8, 8),
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
              const Icon(Icons.cloud_queue_rounded,
                  color: AppColors.textLight, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thời tiết: ${day.weatherForecast}',
                      style: const TextStyle(
                          color: AppColors.textLight, fontWeight: FontWeight.w600),
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
                Text('Mẹo AI',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.secondaryOrange)),
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
                    fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.notes,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Xem Địa điểm'),
                        onPressed: () {
                          // Giả lập tìm địa điểm theo placeId
                          final place = mockPlaces.firstWhere(
                              (p) => p.id == activity.placeId,
                              orElse: () => mockPlaces.first);
                          Navigator.pushNamed(context, '/place_detail', arguments: place);
                        },
                      ),
                    )
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
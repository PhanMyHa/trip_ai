class Itinerary {
  final String id;
  final String itineraryId;
  final String userId;
  final String destination;
  final TravelProfile travelProfile;
  final List<ItineraryDay> schedule;
  final bool isSaved;
  final bool aiGenerated;
  final DateTime createdAt;

  Itinerary({
    required this.id,
    required this.itineraryId,
    required this.userId,
    required this.destination,
    required this.travelProfile,
    required this.schedule,
    this.isSaved = false,
    this.aiGenerated = false,
    required this.createdAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['_id'] ?? '',
      itineraryId: json['itineraryId'] ?? '',
      userId: json['userId'] ?? '',
      destination: json['destination'] ?? '',
      travelProfile: TravelProfile.fromJson(json['travelProfile'] ?? {}),
      schedule: (json['schedule'] as List? ?? [])
          .map((day) => ItineraryDay.fromJson(day))
          .toList(),
      isSaved: json['isSaved'] ?? false,
      aiGenerated: json['aiGenerated'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class TravelProfile {
  final int people;
  final String budget;
  final List<String> interests;

  TravelProfile({
    required this.people,
    required this.budget,
    required this.interests,
  });

  factory TravelProfile.fromJson(Map<String, dynamic> json) {
    return TravelProfile(
      people: json['people'] ?? 1,
      budget: json['budget'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}

class ItineraryDay {
  final int day;
  final String title;
  final List<String> activities;

  ItineraryDay({
    required this.day,
    required this.title,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: json['day'] ?? 1,
      title: json['title'] ?? '',
      activities: List<String>.from(json['activities'] ?? []),
    );
  }
}

// lib/models/event.dart
class Event {
  final int id;
  final String name;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;
  final int participantCount; // New
  final int maxParticipants;  // New
  final bool isRegistered;    // New

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.participantCount,
    required this.maxParticipants,
    required this.isRegistered,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: json['date'],
      time: json['time'] ?? "TBA",
      location: json['location'],
      imageUrl: json['image_url'] ?? "",
      participantCount: json['participant_count'] ?? 0,
      maxParticipants: json['max_participants'] ?? 0,
      isRegistered: json['is_registered'] ?? false,
    );
  }
}
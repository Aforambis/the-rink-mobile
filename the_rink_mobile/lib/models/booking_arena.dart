// models/booking_arena.dart

class Arena {
  final String id; // UUID di Django -> String di Dart
  final String name;
  final String description;
  final int capacity;
  final String location;
  final String? imgUrl; // null=True di Django
  final String? openingHoursText;
  final String? googleMapsUrl;

  Arena({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.location,
    this.imgUrl,
    this.openingHoursText,
    this.googleMapsUrl,
  });

  factory Arena.fromJson(Map<String, dynamic> json) {
    return Arena(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as int,
      location: json['location'] as String,
      // Mapping key snake_case dari Django
      imgUrl: json['img_url'] as String?, 
      openingHoursText: json['opening_hours_text'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'location': location,
      'img_url': imgUrl,
      'opening_hours_text': openingHoursText,
      'google_maps_url': googleMapsUrl,
    };
  }
}

class ArenaOpeningHours {
  final int id; 
  final String arenaId; // UUID Arena
  final int day;
  final String? openTime; // Format "HH:MM:SS"
  final String? closeTime;

  ArenaOpeningHours({
    required this.id,
    required this.arenaId,
    required this.day,
    this.openTime,
    this.closeTime,
  });

  String get dayName {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    if (day >= 0 && day < days.length) return days[day];
    return 'Unknown';
  }

  factory ArenaOpeningHours.fromJson(Map<String, dynamic> json) {
    return ArenaOpeningHours(
      id: json['id'] as int,
      // Asumsi serializer Django return arena_id sebagai string UUID
      arenaId: json['arena'] as String, 
      day: json['day'] as int,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arena': arenaId,
      'day': day,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }
}

// --- ENUMS & BOOKING MODEL ---

enum BookingStatus { booked, cancelled, completed, unknown }

enum BookingActivity { iceSkating, iceHockey, curling, other }

class Booking {
  final String id; // UUID
  final String arenaId; // UUID
  final int userId; // Integer (Default Django User ID)
  final DateTime date;
  final int startHour;
  final DateTime bookedAt;
  final BookingStatus status;
  final BookingActivity? activity;

  Booking({
    required this.id,
    required this.arenaId,
    required this.userId,
    required this.date,
    required this.startHour,
    required this.bookedAt,
    required this.status,
    this.activity,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      arenaId: json['arena'] as String,
      userId: json['user'] as int,
      date: DateTime.parse(json['date'] as String), 
      startHour: json['start_hour'] as int,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      // Mapping Status & Activity pas nerima data
      status: _mapStatus(json['status'] as String?),
      activity: _mapActivity(json['activity'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arena': arenaId,
      'user': userId,
      // Format Date YYYY-MM-DD
      'date': date.toIso8601String().split('T').first, 
      'start_hour': startHour,
      'booked_at': bookedAt.toIso8601String(),
      
      // Balikin Status ke Title Case ('Booked') sesuai choices Django
      'status': status.name.capitalize(), 
      
      // Balikin Activity ke snake_case ('ice_skating') sesuai choices Django
      'activity': _activityToSnakeCase(activity), 
    };
  }

  // --- HELPER METHODS ---

  // Dari Django ('Booked') ke Dart Enum
  static BookingStatus _mapStatus(String? val) {
    if (val == null) return BookingStatus.unknown;
    switch (val.toLowerCase()) {
      case 'booked': return BookingStatus.booked;
      case 'cancelled': return BookingStatus.cancelled;
      case 'completed': return BookingStatus.completed;
      default: return BookingStatus.unknown;
    }
  }

  // Dari Django ('ice_skating') ke Dart Enum
  static BookingActivity? _mapActivity(String? val) {
    if (val == null) return null;
    switch (val.toLowerCase()) {
      case 'ice_skating': return BookingActivity.iceSkating;
      case 'ice_hockey': return BookingActivity.iceHockey;
      case 'curling': return BookingActivity.curling;
      default: return BookingActivity.other;
    }
  }

  // Dari Dart Enum ke Django ('ice_skating') -> PENTING BIAR MATCH METADATA
  String? _activityToSnakeCase(BookingActivity? val) {
    if (val == null) return null;
    switch (val) {
      case BookingActivity.iceSkating: return 'ice_skating';
      case BookingActivity.iceHockey: return 'ice_hockey';
      case BookingActivity.curling: return 'curling';
      default: return 'other';
    }
  }
}

// Extension sederhana biar gak perlu import library string ribet-ribet
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
class Arena {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final String location;
  final String? imgUrl; // Nullable karena null=True
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

  // Factory buat bikin object dari JSON (biasanya dari API response)
  factory Arena.fromJson(Map<String, dynamic> json) {
    return Arena(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as int,
      location: json['location'] as String,
      imgUrl: json['img_url'] as String?, // Perhatiin key-nya snake_case sesuai Django
      openingHoursText: json['opening_hours_text'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
    );
  }

  // Method buat balikin ke JSON (kalo mau POST data balik)
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
  final int id; // Django default ID itu integer auto increment
  final String arenaId; // Kita simpen ID-nya aja, bukan object Arena full
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

  // Helper buat dapetin nama hari biar gak pusing angka doang
  String get dayName {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    if (day >= 0 && day < days.length) return days[day];
    return 'Unknown';
  }

  factory ArenaOpeningHours.fromJson(Map<String, dynamic> json) {
    return ArenaOpeningHours(
      id: json['id'] as int,
      // Asumsi serializer lu ngirim arena_id, bukan nested arena object
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

// Enum buat Status
enum BookingStatus { booked, cancelled, completed, unknown }

// Enum buat Activity
enum BookingActivity { iceSkating, iceHockey, curling, other }

class Booking {
  final String id;
  final String arenaId;
  final int userId; 
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
      // Parsing string "YYYY-MM-DD" ke DateTime
      date: DateTime.parse(json['date'] as String), 
      startHour: json['start_hour'] as int,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      // Konversi String ke Enum (Safety first!)
      status: _mapStatus(json['status'] as String?),
      activity: _mapActivity(json['activity'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arena': arenaId,
      'user': userId,
      'date': date.toIso8601String().split('T').first, // Ambil tanggalnya aja
      'start_hour': startHour,
      'booked_at': bookedAt.toIso8601String(),
      'status': status.name.capitalize(), // Balikin ke format text Django (opsional)
      'activity': activity?.name, // Snake case handling mungkin butuh logic tambahan
    };
  }

  // Helper methods buat mapping Enum
  static BookingStatus _mapStatus(String? val) {
    switch (val?.toLowerCase()) {
      case 'booked': return BookingStatus.booked;
      case 'cancelled': return BookingStatus.cancelled;
      case 'completed': return BookingStatus.completed;
      default: return BookingStatus.unknown;
    }
  }

  static BookingActivity? _mapActivity(String? val) {
    switch (val?.toLowerCase()) {
      case 'ice_skating': return BookingActivity.iceSkating;
      case 'ice_hockey': return BookingActivity.iceHockey;
      case 'curling': return BookingActivity.curling;
      default: return null;
    }
  }
}

// Extension kecil buat string manipulation kalo perlu
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
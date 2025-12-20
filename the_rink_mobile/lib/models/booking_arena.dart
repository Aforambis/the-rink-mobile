import 'dart:convert';

class Arena {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final String location;
  final String? imgUrl;
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
      id: json['id'].toString(), 
      name: json['name'] ?? "Unknown Arena",
      description: json['description'] ?? "-",
      capacity: json['capacity'] ?? 0,
      location: json['location'] ?? "-",
      imgUrl: json['img_url'],
      openingHoursText: json['opening_hours_text'],
      googleMapsUrl: json['google_maps_url'],
    );
  }
}

enum BookingStatus { booked, cancelled, completed, unknown }
enum BookingActivity { iceSkating, iceHockey, curling, other }

class Booking {
  final String? id; 
  final String? arenaName;
  final String? arenaId;   
  final DateTime? date;
  final int startHour;
  final bool isMine;
  final BookingStatus status;
  final BookingActivity? activity;

  Booking({
    this.id,
    this.arenaName,
    this.arenaId,
    this.date,
    required this.startHour,
    this.isMine = false,
    required this.status,
    this.activity,
  });

  // 1. Factory buat response 'get_bookings_flutter' (Cek Slot)
  // JSON: {"start_hour": 10, "status": "Booked", "is_mine": true}
  factory Booking.fromSlotJson(Map<String, dynamic> json) {
    return Booking(
      startHour: json['start_hour'],
      status: _mapStatus(json['status']),
      isMine: json['is_mine'] ?? false,
    );
  }

  // 2. Factory buat response 'my_history_flutter' (History User)
  // JSON: {"id": "uuid", "arena_name": "Rink A", "date": "2023-...", ...}
  factory Booking.fromHistoryJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      arenaName: json['arena_name'],
      date: DateTime.tryParse(json['date'] ?? ""),
      startHour: json['start_hour'],
      status: _mapStatus(json['status']),
      activity: _mapActivity(json['activity']),
      isMine: true, // Karena ini history user, pasti punya dia
    );
  }

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
      default: return BookingActivity.other;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
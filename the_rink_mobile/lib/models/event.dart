class Event {
  final int id;
  final String name;
  final String description;
  final String date;
  final String time;
  final String location;
  final double price; 
  final String category; 
  final String imageUrl;
  final int participantCount;
  final int maxParticipants;
  final bool isRegistered;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.category,
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
      time: json['time'],
      location: json['location'],
      // Pastikan konversi ke double aman (kadang Django kirim int)
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'], 
      category: json['category'],
      // Handle image URL: Jika string kosong, biarkan kosong. 
      // Nanti UI yang handle gambar default.
      imageUrl: json['image_url'] ?? "", 
      participantCount: json['participant_count'] ?? 0,
      maxParticipants: json['max_participants'] ?? 0,
      isRegistered: json['is_registered'] ?? false,
    );
  }
}